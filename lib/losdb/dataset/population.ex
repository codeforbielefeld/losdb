defmodule LOSDB.Dataset.Population do
  import RDF.Sigils

  alias RDF.XSD
  alias RDF.NS.{RDFS}
  alias RDF.Vocab.{Schema, DC, CC}
  alias LOSDB.NS.{Vocab, BielVocab, StatBezirk, Bezirk, Cube, SDMX, Wikidata}

  def extract_dataset(input_file, opts) do
    records =
      raw_records(input_file)
      |> Enum.filter(fn [_, _, _, _, _, _, geschlecht, _, _] -> geschlecht != "3" end)

    cube_dataset = cube_dataset(records, opts)

    metadata =
      RDF.Graph.new()
      |> RDF.Graph.add(cube_dataset)
      |> RDF.Graph.add(LOSDB.statistikstelle())

    graph =
      Enum.reduce(records, metadata, fn record, graph ->
        RDF.Graph.add(graph, cube_observation(record, cube_dataset.subject))
      end)

    cond do
      output_file = Keyword.get(opts, :out) -> write_dataset(graph, opts)
      true -> graph
    end
  end

  defp write_dataset(graph, opts) do
    dest = Keyword.get(opts, :out) <> "/" <> Keyword.get(opts, :name) <> ".ttl"

    graph
    |> RDF.Turtle.write_file!(dest,
      # TODO: Remove force
      force: true,
      prefixes: LOSDB.NS.prefixes()
    )
  end

  # recommend core set of metadata terms: https://www.w3.org/TR/vocab-data-cube/#metadata
  def cube_dataset(records, opts) do
    dataset_iri(opts)
    |> RDF.type(Cube.DataSet)
    |> DC.publisher(LOSDB.statistikstelle_id())
    |> DC.subject(
      # Population and migration
      ~I<http://purl.org/linked-data/sdmx/2009/subject#1.1>,
      # Regional and small area statistics
      ~I<http://purl.org/linked-data/sdmx/2009/subject#3.2>,
      # Bielefeld
      Wikidata.Q2112
    )
    |> DC.license(~I<http://creativecommons.org/licenses/by-sa/4.0/>)
  end

  def dataset_iri(opts) do
    # TODO: mint URI
    Keyword.get(opts, :name)
    |> RDF.bnode()
  end

  def cube_observation(
        [stichtag, _, _, _, _, stat_id_k, geschlecht, age4, einwohnerzahl],
        dataset
      ) do
    RDF.bnode()
    |> RDF.type(Cube.Observation)
    |> Cube.dataSet(dataset)
    |> Vocab.population(XSD.integer(einwohnerzahl))
    |> Vocab.refPeriod(year(stichtag))
    |> Vocab.place(StatBezirk.iri(stat_id_k))
    |> Vocab.gender(geschlecht(geschlecht))
    |> Vocab.ageGroup(ageGroup(age4))
  end

  def year(date) do
    (date |> Timex.parse!("{0D}{0M}{YYYY}") |> Timex.to_date()).year
    |> RDF.literal(datatype: RDF.NS.XSD.gYear())
  end

  def geschlecht("1"), do: SDMX.Code.sexM()
  def geschlecht("2"), do: SDMX.Code.sexF()

  def ageGroup("1"), do: Vocab.AgeBelow18
  def ageGroup("2"), do: Vocab.Age18to64
  def ageGroup("3"), do: Vocab.Age65to79
  def ageGroup("4"), do: Vocab.AgeAbove80

  ################################################################################################
  # Extraktion der Bezirke
  ################################################################################################

  def extract_bezirke(input_file) do
    input_file
    |> raw_records()
    # TODO: skip already existing
    |> Enum.reduce(RDF.Graph.new(), fn record, graph ->
      RDF.Graph.add(graph, bezirk(record))
    end)
  end

  def extract_bezirke(input_file, output_file) do
    input_file
    |> extract_bezirke()
    |> RDF.Turtle.write_file!(output_file,
      # TODO: Remove force
      force: true,
      prefixes: LOSDB.NS.prefixes()
    )
  end

  def raw_records(file) do
    file
    |> File.read!()
    |> Parser.parse_string()
  end

  def bezirk([_, stad_name, stad_id_k, stat_name, stat_id, stat_id_k, _, _, _]) do
    RDF.Graph.new()
    |> RDF.Graph.add(
      stad_name
      |> Bezirk.iri()
      |> RDF.type(Schema.AdministrativeArea)
      |> RDFS.label(stad_name)
    )
    |> RDF.Graph.add(
      stat_id_k
      |> StatBezirk.iri()
      |> RDF.type(Schema.Place)
      |> RDFS.label(stat_name)
      |> BielVocab.bezirk(Bezirk.iri(stad_name))
    )
  end
end
