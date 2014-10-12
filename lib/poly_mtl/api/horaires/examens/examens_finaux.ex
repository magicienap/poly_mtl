defmodule PolyMtl.Api.Horaire.Examens.ExamensFinaux do
  import PolyMtl.Api.Horaire.Examens.Commun

  @uri_horaire_examens_finaux "http://www.polymtl.ca/etudes/horaires/horaire_exam_finaux.php"

  def obtenir do
    page = obtenir_page(@uri_horaire_examens_finaux)

    {
      extraire_examens_finaux(page),
      extraire_date_mise_a_jour(page)
    }
  end

  defp extraire_examens_finaux(page) do
    page
      |> xpath("//table/tr")
      |> Enum.drop(4)
      |> Enum.map &extraire_examen_final/1
  end

  defp extraire_examen_final(examen_final) do
    donnees = extraire_donnees(examen_final)

    %PolyMtl.Examen{
      sigle:  Enum.at(donnees, 0),
      groupe: extraire_groupe(Enum.at(donnees, 1)),
      date:   extraire_date_ef(Enum.at(donnees, 3)),
      heure:  extraire_heure_ef(Enum.at(donnees, 4)),
      salle:  Enum.at(donnees, 5),
      noms:   separer_noms(Enum.at(donnees, 6))
    }
  end

  defp extraire_date_ef(chaine) do
    {{annee, _, _}, _} = :calendar.local_time
    [jour, mois] = String.split(chaine, " ")
    mois = extraire_mois(mois)
    jour = jour |> String.to_integer

    {annee, mois, jour}
  end

  defp extraire_heure_ef("AM"), do: { 9, 30}
  defp extraire_heure_ef("PM"), do: {13, 30}
  defp extraire_heure_ef("S"),  do: {19,  0}
end