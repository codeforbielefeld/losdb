defmodule LOSDB.Dataset.Household do
  alias RDF.XSD
  alias LOSDB.NS.{Vocab, StatBezirk, Cube, Wikidata}

  import RDF.Sigils
  import LOSDB.Dataset

  @datasource "priv/data/haushalte/haushalte2009bis2020.csv"
  @anzahl_personen_dataset_name :haushalte_anzahl_personen
  @anzahl_kinder_dataset_name :haushalte_anzahl_kinder
  @wohngemeinschaft_data_name :haushalte_wohngemeinschaften

  def extract_datasets(opts \\ []) do
    extract_datasets(@datasource, opts)
  end

  def extract_datasets(input_file, opts) do
    records = raw_csv_records(input_file)

    extract_dataset(@anzahl_personen_dataset_name, records, opts)
    extract_dataset(@anzahl_kinder_dataset_name, records, opts)
    extract_dataset(@wohngemeinschaft_data_name, records, opts)
  end

  def extract_dataset(dataset_name, records, opts) do
    opts = Keyword.put(opts, :dataset_name, to_string(dataset_name))

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
        RDF.Graph.add(graph, cube_observation(dataset_name, record, cube_dataset.subject))
      end)

    write(graph, opts)
  end

  def cube_observation(
        @anzahl_personen_dataset_name,
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
    [
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

  def cube_observation(
        @anzahl_kinder_dataset_name,
        [
          _stichtag,
          jahr,
          stat_id,
          _stat_name,
          _hh_insgesamt,
          _einPersonenHaushalte,
          _zweiPersonenHaushalte,
          _dreiOderMehrPersonenHaushalte,
          hh_keineKinder,
          _haushalt_mitKindern_insgesamt,
          hh_ein_Kind,
          hh_zwei_Kinder,
          hh_drei_oder_mehrKindern,
          _hh_EhePaareohneKinder_evtl_weiterePersonen,
          _hh_EhePaaremitKindern_evtl_weiterePersonen,
          _hh_Alleinerziehende_ohne_weiterePersonen,
          _hh_SonstigeMehrpersonenhaushalte
        ],
        dataset
      ) do
    [
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.childrenPerHousehold(Vocab.NoChildHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_keineKinder)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.childrenPerHousehold(Vocab.OneChildHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_ein_Kind)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.childrenPerHousehold(Vocab.TwoChildrenHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_zwei_Kinder)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.childrenPerHousehold(Vocab.ThreeOrMoreChildrenHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_drei_oder_mehrKindern))
    ]
  end

  def cube_observation(
        @wohngemeinschaft_data_name,
        [
          _stichtag,
          jahr,
          stat_id,
          _stat_name,
          _hh_insgesamt,
          _einPersonenHaushalte,
          _zweiPersonenHaushalte,
          _dreiOderMehrPersonenHaushalte,
          _hh_keineKinder,
          _haushalt_mitKindern_insgesamt,
          _hh_ein_Kind,
          _hh_zwei_Kinder,
          _hh_drei_oder_mehrKindern,
          hh_EhePaareohneKinder_evtl_weiterePersonen,
          hh_EhePaaremitKindern_evtl_weiterePersonen,
          hh_Alleinerziehende_ohne_weiterePersonen,
          hh_SonstigeMehrpersonenhaushalte
        ],
        dataset
      ) do
    [
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.householdCommunity(Vocab.CoupleWithoutKidsHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_EhePaareohneKinder_evtl_weiterePersonen)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.householdCommunity(Vocab.CoupleWithKidsHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_EhePaaremitKindern_evtl_weiterePersonen)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.householdCommunity(Vocab.SingleParentHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_Alleinerziehende_ohne_weiterePersonen)),
      RDF.bnode()
      |> RDF.type(Cube.Observation)
      |> Cube.dataSet(dataset)
      |> Vocab.refPeriod(RDF.literal(jahr, datatype: RDF.NS.XSD.gYear()))
      |> Vocab.place(StatBezirk.iri("0" <> stat_id))
      |> Vocab.householdCommunity(Vocab.OtherMultiPersonHousehold)
      |> Vocab.numberOfHouseholds(XSD.integer(hh_SonstigeMehrpersonenhaushalte))
    ]
  end
end
