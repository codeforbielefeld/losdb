defmodule LOSDB.NS do
  use RDF.Vocabulary.Namespace

  defmodule Dataset do
    @base LOSDB.losdb_base() <> "datasets/"
    def base(), do: @base
    def iri(name), do: RDF.iri(@base <> to_string(name))
  end

  defmodule Bezirk do
    @base LOSDB.kg_base() <> "bezirke/"
    def base(), do: @base
    def iri(name), do: RDF.iri(@base <> to_string(name))
  end

  defmodule StatBezirk do
    @base LOSDB.kg_base() <> "stat_bezirke/"
    def base(), do: @base
    def iri(id), do: RDF.iri(@base <> to_string(id))
  end

  @vocabdoc """
  The Linked Open Statistical Data Bielefeld vocabulary.
  """
  defvocab Vocab,
    base_iri: "http://bielefeld.codefor.de/losdb/vocab#",
    file: "losdb-vocab.ttl",
    alias: [
      Age18to64: "Age18-64",
      Age65to79: "Age65-79"
    ]

  @vocabdoc """
  The Code for Bielefeld vocabulary.
  """
  defvocab BielVocab,
    base_iri: "http://bielefeld.codefor.de/kg/vocab#",
    terms: ~w[
      bezirk
    ]

  defvocab Wikidata,
    base_iri: "http://www.wikidata.org/entity/",
    terms: [],
    strict: false

  @vocabdoc """
  The RDF Data Cube vocabulary.

  See <https://www.w3.org/TR/vocab-data-cube/>
  """
  defvocab Cube,
    base_iri: "http://purl.org/linked-data/cube#",
    file: "ext/cube.ttl"

  defmodule SDMX do
    defvocab Measure,
      base_iri: "http://purl.org/linked-data/sdmx/2009/measure#",
      file: "ext/sdmx-measure.ttl"

    defvocab Dimension,
      base_iri: "http://purl.org/linked-data/sdmx/2009/dimension#",
      file: "ext/sdmx-dimension.ttl"

    defvocab Attribute,
      base_iri: "http://purl.org/linked-data/sdmx/2009/attribute#",
      file: "ext/sdmx-attribute.ttl"

    defvocab Concept,
      base_iri: "http://purl.org/linked-data/sdmx/2009/concept#",
      file: "ext/sdmx-concept.ttl",
      case_violations: :ignore

    defvocab Code,
      base_iri: "http://purl.org/linked-data/sdmx/2009/code#",
      #      file: "ext/sdmx-code.ttl"
      terms: ["sex-F", "sex-M"],
      alias: [
        sexF: "sex-F",
        sexM: "sex-M"
      ]
  end

  @vocabdoc """
  The Dublin Core Metadata Terms vocabulary.

  See <http://purl.org/dc/terms/>
  """
  defvocab DC,
    base_iri: "http://purl.org/dc/terms/",
    file: "ext/dcterms.nt",
    alias: [
      ISO639_2: "ISO639-2",
      ISO639_3: "ISO639-3"
    ],
    case_violations: :fail

  @vocabdoc """
  The Schema.org vocabulary.

  See <http://schema.org>
  """
  defvocab SchemaOrg,
    base_iri: "http://schema.org/",
    file: "ext/schema.nt",
    case_violations: :ignore

  @vocabdoc """
  The Organization Ontology.

  See <https://www.w3.org/TR/vocab-org/>
  """
  defvocab Org,
    base_iri: "http://www.w3.org/ns/org#",
    file: "ext/org.nt",
    case_violations: :fail

  @prefixes RDF.PrefixMap.new(
              losdb: Vocab,
              bi: BielVocab,
              bezirk: Bezirk.base(),
              statBezirk: StatBezirk.base(),
              xsd: RDF.NS.XSD,
              rdf: RDF.NS.RDF,
              rdfs: RDF.NS.RDFS,
              owl: RDF.NS.OWL,
              skos: RDF.NS.SKOS,
              cube: Cube,
              sdmx_code: SDMX.Code,
              schema: SchemaOrg,
              wd: Wikidata,
              dc: DC,
              foaf: FOAF,
              org: Org
            )

  def prefixes, do: @prefixes
end
