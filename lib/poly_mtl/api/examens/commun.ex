defmodule PolyMtl.Api.Examens.Commun do
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
    remplacer_espaces(chaine, " ")
  end

  defp remplacer_espaces(chaine, remplacement) do
    String.replace(chaine, ~r/\s+/u, remplacement)
  end


  def extraire_heure(heure) do
    [heures, minutes] =
      heure
        |> supprimer_espaces
        |> String.split("h")
        |> Enum.map(&String.to_integer/1)

    {heures, minutes}
  end

  def extraire_mois(mois) do
    tous_mois = ["", "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"]

    Enum.find_index(tous_mois, fn (m)-> mois == m end)
  end
end