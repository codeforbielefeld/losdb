defmodule LOSDB do
  alias RDF.NS.{RDFS}
  alias RDF.Vocab.{FOAF, Org, Schema}

  @code4bielefeld_base "http://bielefeld.codefor.de/"
  @kg_base @code4bielefeld_base <> "kg/"
  @losdb_base @code4bielefeld_base <> "losdb/"

  def code4bielefeld_base, do: @code4bielefeld_base
  def kg_base, do: @kg_base
  def losdb_base, do: @losdb_base

  def statistikstelle_id, do: RDF.iri(@kg_base <> "Stadt-Bielefeld-Statistikstelle")

  def statistikstelle do
    address =
      RDF.bnode()
      |> RDF.type(Schema.PostalAddress)
      |> Schema.streetAddress("Niederwall 25")
      |> Schema.postalCode("33602")
      |> Schema.addressLocality("Bielefeld")

    [
      address,
      statistikstelle_id()
      |> RDF.type(Org.Organization, Schema.GovernmentOrganization, FOAF.Agent)
      |> RDFS.label("Stadt Bielefeld, Presseamt/Statistikstelle")
      |> Schema.address(address.subject)
      |> RDFS.seeAlso("https://www.bielefeld.de/de/rv/ds_stadtverwaltung/presse/stas/")
    ]
  end
end
