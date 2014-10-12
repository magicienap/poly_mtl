defmodule PolyMtl.Mixfile do
  use Mix.Project

  def project do
    [app: :poly_mtl,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      { :httpoison, "~> 0.4" },
      { :mochiweb_xpath, github: "retnuh/mochiweb_xpath" },
      { :ux, github: "erlang-unicode/ux" }
    ]
  end
end
