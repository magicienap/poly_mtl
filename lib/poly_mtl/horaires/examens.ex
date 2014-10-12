defmodule PolyMtl.Horaires.Examens do
  def extraire_pour(nom_complet, liste_cours) do
    extraire_pour(nom_complet, liste_cours,
                  [:controles_periodiques, :examens_finaux])
  end

  def extraire_pour(nom_complet, liste_cours, types_examens)
  when is_list(types_examens) do
    Enum.map types_examens, fn (type)->
      {type, extraire_pour(nom_complet, liste_cours, type)}
    end
  end

  def extraire_pour(nom_complet, liste_cours, type) do
    {liste_examens, date_mise_a_jour} =
      case type do
        :controles_periodiques ->
          PolyMtl.Api.Horaire.Examens.ControlesPeriodiques.obtenir
        :examens_finaux ->
          PolyMtl.Api.Horaire.Examens.ExamensFinaux.obtenir
      end

    {filtrer_examens(liste_examens, nom_complet, liste_cours), date_mise_a_jour}
  end

  # Parmi la liste des examens, quels sont les miens?
  def filtrer_examens(liste_examens, nom_complet, liste_cours) do
    liste_examens |> Enum.filter &mon_examen?(&1, nom_complet, liste_cours)
  end

  # Est-ce l'évaluation d'un de mes cours-groupe?
  defp mon_examen?(examen, nom_complet, liste_cours) do
    liste_cours |> Enum.find &mon_cours_groupe?(examen, &1, nom_complet)
  end

  # Est-ce le même sigle de cours, le même groupe et,
  # si la classe est divisée, s'agit-il de mon local?
  # defp mon_cours_groupe?(examen, cours, nom_complet)
  defp mon_cours_groupe?(
    %PolyMtl.Examen{sigle: sigle,
                    groupe: :tous,
                    noms: nil},
    {sigle, _}, _),
    do: true
  defp mon_cours_groupe?(
    %PolyMtl.Examen{sigle: sigle,
                    groupe: groupe,
                    noms: nil},
    {sigle, groupe}, _),
    do: true
  defp mon_cours_groupe?(
    %PolyMtl.Examen{sigle: sigle,
                    groupe: groupe,
                    noms: noms},
    {sigle, groupe},
    nom_complet),
    do: nom_inclus?(nom_complet, noms)
  defp mon_cours_groupe?(_, _, _), do: false

  def nom_inclus?({mon_nom, mon_prenom},
                  {{nom_debut, prenom_debut},
                   {nom_fin, prenom_fin}}) do
    cond do
           c(mon_nom, nom_debut) == :greater
      and  c(mon_nom, nom_fin)   == :lower             -> true
           c(mon_nom, nom_debut) == :equal
      and    (c(mon_prenom, prenom_debut) == :equal
          or  c(mon_prenom, prenom_debut) == :greater) -> true
          c(mon_nom, nom_fin) == :equal
      and     (c(mon_prenom, prenom_fin) == :equal
           or  c(mon_prenom, prenom_fin) == :lower)    -> true
      true -> false
    end
  end

  def c(a, b) do
    [a, b] = Enum.map [a, b], &normaliser_pour_comparaison/1
    :ux_uca.compare(a, b)
  end

  # Enlève la ponctuation et les espaces
  defp normaliser_pour_comparaison(chaine) do
    chaine
      |> String.replace(~r/\p{P}|\p{Z}/u, "")
      |> to_char_list
  end
end