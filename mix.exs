defmodule LOSDB.MixProject do
  use Mix.Project

  def project do
    [
      app: :losdb,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rdf, "~> 2.0"},
      {:foaf, "~> 0.1"},
      {:nimble_csv, "~> 1.0"},
      {:timex, "~> 3.6"}
    ]
  end
end
