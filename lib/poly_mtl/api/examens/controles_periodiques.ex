defmodule PolyMtl.Api.Examens.ControlesPeriodiques do
  import PolyMtl.Api.Examens.Commun

  @uri_horaire_controles_periodiques "http://www.polymtl.ca/etudes/horaires/horaire_contr_per.php"

  def obtenir do
    page = obtenir_page(@uri_horaire_controles_periodiques)

    {
      extraire_controles_periodiques(page),
      extraire_date_mise_a_jour(page)
    }
  end

  defp extraire_controles_periodiques(page) do
    page
      |> xpath("//table/tr")
      |> tl
      |> Enum.map &extraire_controle_periodique/1
  end

  defp extraire_controle_periodique(controle_periodique) do
    donnees = xpath(controle_periodique, "//tr/td/text()")

    %PolyMtl.Examen{
        sigle:  Enum.at(donnees, 0),
        groupe: Enum.at(donnees, 1),
        date:   extraire_date_cp(Enum.at(donnees, 3), Enum.at(donnees, 4)),
        heure:  extraire_heure(Enum.at(donnees, 5)),
        salle:  Enum.at(donnees, 6),
        noms:   extraire_noms_cp(Enum.at(donnees, 7))
      }
  end

  defp extraire_date_cp(jour, mois) do
    {{annee, _, _}, _} = :calendar.local_time
    mois = extraire_mois(mois)
    jour = jour |> supprimer_espaces |> String.to_integer

    {annee, mois, jour}
  end

  defp extraire_noms_cp(nil), do: nil
  defp extraire_noms_cp(noms) do
    noms = noms |> normaliser_espaces |> String.strip

    if noms == "" do
      nil
    else
      separer_noms(noms)
    end
  end

  defp separer_noms(noms) do
    [_, nom_debut, prenom_debut, nom_fin, prenom_fin] =
        Regex.run(~r/de: ([^,]+), ([^,]+)(?: à |, )([^,]+), ([^,]+)/u, noms)
    {{nom_debut, prenom_debut}, {nom_fin, prenom_fin}}
  end

  defp extraire_date_mise_a_jour(page) do
    fragment = xpath(page, "//div[@id=\"contenu-texte\"]/p")
    [_, date | _] = fragment
    [date] = xpath(date, "//b/text()")
    [_, jour, mois, annee] = Regex.run(~r/\(mise à jour : (\d{1,2}) (\w+) (\d{4})\)/, date)

    annee = String.to_integer(annee)
    mois  = extraire_mois(mois)
    jour  = String.to_integer(jour)

    {annee, mois, jour}
  end
end