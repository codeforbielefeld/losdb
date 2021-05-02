defmodule LOSDB.Dataset do
  alias LOSDB.NS.{Cube, SDMX, Wikidata}
  alias RDF.Vocab.{Schema, DC, CC}

  import RDF.Sigils

  @default_output_dir "output"

  # recommend core set of metadata terms: https://www.w3.org/TR/vocab-data-cube/#metadata
  def cube_dataset(opts) do
    subjects = Keyword.get(opts, :subjects, [Wikidata.Q2112])

    iri(opts)
    |> RDF.type(Cube.DataSet)
    |> DC.publisher(LOSDB.statistikstelle_id())
    |> DC.subject(subjects)
    |> DC.license(~I<http://creativecommons.org/licenses/by-sa/4.0/>)
  end

  def iri(opts) do
    # TODO: mint URI
    Keyword.get(opts, :name)
    |> RDF.bnode()
  end

  def raw_csv_records(file) do
    file
    |> File.read!()
    |> Parser.parse_string()
  end

  def write(graph, opts) do
    dest =
      Keyword.get(opts, :path, @default_output_dir) <> "/" <> Keyword.get(opts, :name) <> ".ttl"

    graph
    |> RDF.Turtle.write_file!(dest,
      force: true,
      prefixes: LOSDB.NS.prefixes()
    )
  end
end
