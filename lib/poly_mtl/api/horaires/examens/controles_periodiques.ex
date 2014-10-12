defmodule PolyMtl.Api.Horaire.Examens.ControlesPeriodiques do
  import PolyMtl.Api.Horaire.Examens.Commun

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
    donnees = extraire_donnees(controle_periodique)

    %PolyMtl.Examen{
      sigle:  Enum.at(donnees, 0),
      groupe: extraire_groupe(Enum.at(donnees, 1)),
      date:   extraire_date_cp(Enum.at(donnees, 3), Enum.at(donnees, 4)),
      heure:  extraire_heure(Enum.at(donnees, 5)),
      salle:  Enum.at(donnees, 6),
      noms:   separer_noms(Enum.at(donnees, 7))
    }
  end

  defp extraire_date_cp(jour, mois) do
    {{annee, _, _}, _} = :calendar.local_time
    mois = extraire_mois(mois)
    jour = jour |> supprimer_espaces |> String.to_integer

    {annee, mois, jour}
  end
end