defmodule LOSDB do
  alias RDF.NS.{RDFS}
  alias RDF.Vocab.{DC, FOAF, Org, Schema}

  @code4bielefeld_base "http://know.bielefeld.de/"
  @kg_base @code4bielefeld_base <> ""
  @losdb_base @code4bielefeld_base <> "losdb/"

  def code4bielefeld_base, do: @code4bielefeld_base
  def kg_base, do: @kg_base
  def losdb_base, do: @losdb_base

  # TODO: introduce vocabulary namespace
  def statistikstelle_id, do: RDF.iri(@code4bielefeld_base <> "statistikstelle")

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
