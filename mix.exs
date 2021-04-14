defmodule LOSDB.MixProject do
  use Mix.Project

  def project do
    [
      app: :losdb,
      version: "0.1.0",
      elixir: "~> 1.10",
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
      {:rdf, "~> 0.9"},
      {:rdf_vocab, "~> 0.2"},
      {:nimble_csv, "~> 0.6"},
      {:timex, "~> 3.6"}
    ]
  end
end
