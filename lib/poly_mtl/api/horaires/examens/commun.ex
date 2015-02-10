defmodule PolyMtl.Api.Horaire.Examens.Commun do
  def obtenir_page(uri) do
    HTTPoison.start
    %HTTPoison.Response{body: page} = HTTPoison.get uri

    page
      |> :unicode.characters_to_binary(:latin1)
      |> :mochiweb_html.parse
  end

  def xpath(fragment, chemin) do
    :mochiweb_xpath.execute(to_char_list(chemin), fragment)
  end


  # Inclut aussi les espaces insécables (comme &nbsp;)
  def supprimer_espaces(chaine) do
    remplacer_espaces(chaine, "")
  end

  def normaliser_espaces(chaine) do
    remplacer_espaces(chaine, " ") |> String.strip
  end

  defp remplacer_espaces(chaine, remplacement) do
    String.replace(chaine, ~r/\s+/u, remplacement)
  end

  def nilifier(""),     do: nil
  def nilifier(chaine), do: chaine


  def extraire_donnees(examen) do
    xpath(examen, "//tr/td/text()")
      |> Enum.map(&normaliser_espaces/1)
      |> Enum.map(&nilifier/1)
  end

  def extraire_groupe("Tous"), do: :tous
  def extraire_groupe(nil),    do: :tous
  def extraire_groupe(groupe), do: String.to_integer(groupe)

  def extraire_heure(nil),  do: {nil, nil}
  def extraire_heure("AM"), do: { 9, 30}
  def extraire_heure("PM"), do: {13, 30}
  def extraire_heure("S"),  do: {19,  0}
  def extraire_heure(heure)  do
    heure_separee = 
      heure
        |> supprimer_espaces
        |> String.split("h")

    [heures, minutes] =
      case heure_separee do
        [_, ""] -> [Enum.at(heure_separee, 0), "0"]
        _ -> heure_separee
      end
        |> Enum.map(&String.to_integer/1)

    {heures, minutes}
  end

  def extraire_mois(mois) do
    tous_mois = ["", "janvier", "février", "mars", "avril", "mai", "juin",
                 "juillet", "août", "septembre", "octobre", "novembre",
                 "décembre"]
    mois = supprimer_espaces(mois) |> String.downcase

    Enum.find_index(tous_mois, fn (m)-> mois == m end)
  end

  def separer_noms(nil), do: nil
  def separer_noms(noms) do
    # En théorie, ce devrait être Regex.run(~r/[d|D]e:\s*([^,]+),\s*([^,]+)(?: à |, )([^,]+),\s*([^,]+)/u, noms)
    # Toutefois, les données ne sont pas uniformes
    [_, nom_debut, prenom_debut, nom_fin, prenom_fin] =
        Regex.run(~r/[d|D]e:\s*([^,]+),\s*([^,]+)(?:\s?à |, )([^,]+),\s*([^,]+)/u, noms) ||
         # Ces lignes ne devraient pas être présentes, mais les données ne sont pas uniformes!
        Regex.run(~r/[d|D]e:\s*([^,]+),\s*([^,]+)(?: à |, )([^,]+)\s*([^,]+)/u, noms) ||
        (Regex.run(~r/[d|D]e:\s*([^,]+),\s*([^,]+) à/u, noms) ++ [nil, nil])
    {{nom_debut, prenom_debut}, {nom_fin, prenom_fin}}
  end

  def extraire_date_mise_a_jour(page) do
    fragment = xpath(page, "//div[@id=\"contenu-texte\"]/p")
    [_, date | _] = fragment
    [date] = xpath(date, "//b/text()")

    [_, jour, mois, annee] =
      Regex.run(~r/\(mise à jour : (\d{1,2})\s* (\w+)\s*(\d{4})\)/u, date)

    annee = String.to_integer(annee)
    mois  = extraire_mois(mois)
    jour  = String.to_integer(jour)

    {annee, mois, jour}
  end
end