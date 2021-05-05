defmodule LOSDB.Dataset.Household do
  alias RDF.XSD
  alias RDF.NS.{RDFS}
  alias LOSDB.NS.{Vocab, BielVocab, StatBezirk, Bezirk, Cube, SDMX, Wikidata}

  import RDF.Sigils
  import LOSDB.Dataset

  @datasource "data/haushalte/haushalte2009bis2020.csv"
  @dataset_name "haushalte_anzahl_personen"

  def extract_dataset(opts \\ []) do
    extract_dataset(
      @datasource,
      Keyword.put_new(opts, :dataset_name, @dataset_name)
    )
  end

  def extract_dataset(input_file, opts) do
    records = raw_csv_records(input_file)

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
      RDF.Graph.new()
      |> RDF.Graph.add(cube_dataset)
      |> RDF.Graph.add(LOSDB.statistikstelle())

    graph =
      Enum.reduce(records, metadata, fn record, graph ->
        RDF.Graph.add(graph, cube_observation(record, cube_dataset.subject))
      end)

    case Keyword.pop(opts, :write, false) do
      {false, opts} -> graph
      {true, opts} -> write(graph, opts)
    end
  end

  def cube_observation(
        [
          _stichtag,
          jahr,
          stat_id,
          _stat_name,
          _hh_insgesamt,
          einPersonenHaushalte,
          zweiPersonenHaushalte,
          dreiOderMehrPersonenHaushalte,
          _hh_keineKinder,
          _haushalt_mitKindern_insgesamt,
          _hh_ein_Kind,
          _hh_zwei_Kinder,
          _hh_drei_oder_mehrKindern,
          _hh_EhePaareohneKinder_evtl_weiterePersonen,
          _hh_EhePaaremitKindern_evtl_weiterePersonen,
          _hh_Alleinerziehende_ohne_weiterePersonen,
          _hh_SonstigeMehrpersonenhaushalte
        ],
        dataset
      ) do
    base_observation = [
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.peoplePerHousehold(Vocab.OnePersonHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(einPersonenHaushalte)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.peoplePerHousehold(Vocab.TwoPersonHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(zweiPersonenHaushalte)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.peoplePerHousehold(Vocab.ThreeOrMorePersonHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(dreiOderMehrPersonenHaushalte))
    ]
  end
end
