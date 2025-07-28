defmodule LOSDB do
  alias RDF.NS.RDFS
  alias LOSDB.NS.{Org, SchemaOrg}

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
      |> RDF.type(SchemaOrg.PostalAddress)
      |> SchemaOrg.streetAddress("Niederwall 25")
      |> SchemaOrg.postalCode("33602")
      |> SchemaOrg.addressLocality("Bielefeld")

    [
      address,
      statistikstelle_id()
      |> RDF.type([Org.Organization, SchemaOrg.GovernmentOrganization, FOAF.Agent])
      |> RDFS.label("Stadt Bielefeld, Presseamt/Statistikstelle")
      |> SchemaOrg.address(address.subject)
      |> RDFS.seeAlso("https://www.bielefeld.de/de/rv/ds_stadtverwaltung/presse/stas/")
    ]
  end
end
