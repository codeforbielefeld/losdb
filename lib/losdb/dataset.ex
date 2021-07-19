defmodule LOSDB.Dataset do
  alias LOSDB.NS
  alias LOSDB.NS.{Cube}
  alias RDF.Vocab.{DC}

  import RDF.Sigils

  @default_output_dir "output"

  # recommend core set of metadata terms: https://www.w3.org/TR/vocab-data-cube/#metadata
  def cube_dataset(opts) do
    subjects = Keyword.get(opts, :subjects, [Wikidata.Q2112])

    Keyword.get(opts, :dataset_name)
    |> NS.Dataset.iri()
    |> RDF.type(Cube.DataSet)
    |> DC.publisher(LOSDB.statistikstelle_id())
    |> DC.subject(subjects)
    |> DC.license(~I<http://creativecommons.org/licenses/by-sa/4.0/>)
  end

  def raw_csv_records(file) do
    file
    |> File.read!()
    |> Parser.parse_string()
  end

  def write(graph, opts) do
    dest =
      Keyword.get(opts, :path, @default_output_dir) <>
        "/" <> Keyword.get(opts, :dataset_name) <> ".ttl"

    graph
    |> RDF.Turtle.write_file!(dest,
      force: true,
      prefixes: LOSDB.NS.prefixes()
    )
  end
end
