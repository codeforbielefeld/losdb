defmodule LOSDB.Dataset.Population do
  alias RDF.XSD
  alias RDF.NS.{RDFS}
  alias RDF.Vocab.Schema
  alias LOSDB.NS.{Vocab, BielVocab, StatBezirk, Bezirk, Cube, SDMX, Wikidata}

  import RDF.Sigils
  import LOSDB.Dataset

  @datasource "priv/data/bev_struktur/bielefeld_bev_struktur_2000bis2019.csv"
  @dataset_name "bev_struktur"

  def extract_dataset(opts \\ []) do
    extract_dataset(
      @datasource,
      Keyword.put_new(opts, :dataset_name, @dataset_name)
    )
  end

  def extract_dataset(input_file, opts) do
    records =
      raw_csv_records(input_file)
      |> Enum.filter(fn [_, _, _, _, _, _, geschlecht, _, _] -> geschlecht != "3" end)

    cube_dataset =
      opts
      |> Keyword.put(:subjects, [
        # Population and migration
        ~I<http://purl.org/linked-data/sdmx/2009/subject#1.1>,
        # Regional and small area statistics
        ~I<http://purl.org/linked-data/sdmx/2009/subject#3.2>,
        # Bielefeld
        Wikidata.Q2112
      ])
      |> cube_dataset()

    metadata =
      RDF.Graph.new(base_iri: cube_dataset.subject)
      |> RDF.Graph.add(cube_dataset)
      |> RDF.Graph.add(LOSDB.statistikstelle())

    graph =
      Enum.reduce(records, metadata, fn record, graph ->
        RDF.Graph.add(graph, cube_observation(record, cube_dataset.subject))
      end)

    case Keyword.pop(opts, :write, false) do
      {false, _opts} -> graph
      {true, opts} -> write(graph, opts)
    end
  end

  def cube_observation(
        [stichtag, _, _, _, stat_id, _, geschlecht, age4, einwohnerzahl],
        dataset
      ) do
    RDF.bnode()
    |> RDF.type(Cube.Observation)
    |> Cube.dataSet(dataset)
    |> Vocab.population(XSD.integer(einwohnerzahl))
    |> Vocab.refPeriod(year(stichtag))
    |> Vocab.place(StatBezirk.iri(stat_id))
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

  def extract_bezirke() do
    extract_bezirke(@datasource, "output/bielefeld-bezirke.ttl")
  end

  def extract_bezirke(input_file) do
    input_file
    |> raw_csv_records()
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

  def bezirk([_, stad_name, _stad_id_k, stat_name, stat_id, _stat_id_k, _, _, _]) do
    RDF.Graph.new()
    |> RDF.Graph.add(
      stad_name
      |> Bezirk.iri()
      |> RDF.type(Schema.AdministrativeArea)
      |> RDFS.label(stad_name)
    )
    |> RDF.Graph.add(
      stat_id
      |> StatBezirk.iri()
      |> RDF.type(Schema.Place)
      |> RDFS.label(stat_name)
      |> BielVocab.bezirk(Bezirk.iri(stad_name))
    )
  end
end
