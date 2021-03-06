# Linked Open Statistical Data Bielefeld (LOSDB)

Linked Data sind Daten, die nicht im klassischen Tabellenformat, sondern als [Knowledge Graph](https://en.wikipedia.org/wiki/Knowledge_graph) vorliegen. Grundlage sind Tripel, bestehend aus jeweils eindeutig per URI identifiziertem Subjekt, Prädikat und Objekt - also zwei Quellen, die zueinander in Relation stellen. Der große Vorteil: Linked Data sind sowohl menschen- als auch maschinenlesbar. Per SPARQL lassen sich auf diese Weise verschiedene Datensätze abrufen und verknüpfen.

Das macht Linked Data auch für statistische Daten interessant. Mehr Infos dazu gibt es beispielsweise bei der Stadt Zürich, die ein [Linked Open Statistical Data](https://www.stadt-zuerich.ch/prd/de/index/statistik/publikationen-angebote/linked-open-statistical-data.html) Portal betreibt. Wir haben als ersten Schritt hin zu einem Knowledge Graph für Bielefeld begonnen, die Datensätze über die Bevölkerungsentwicklung in Bielefeld in Linked Data zu transformieren.

Grundlage ist der [W3C-Standard RDF](https://www.w3.org/RDF/) (Resource Description Framwework). Für den Anwendungsfall statistische Daten haben wir das [RDF Data Cube Vocabulary](https://www.w3.org/TR/vocab-data-cube/) genutzt.

Für Interessierte an Linked Data ist dieser [Kurs vom Hasso-Plattner-Institut](https://open.hpi.de/courses/semanticweb2016?locale=de) zu empfehlen. Außerdem freuen wir uns natürlich über Fragen, Anregungen und neue Mitglieder.


## Datasets

Derzeit können nur die rohen RDF-Daten im Turtle-Format über dieses Repo ([`output`-Ordner](output/)) zugegriffen werden.

- [Bevölkerungsstruktur](output/bev_struktur.ttl)
- [Anzahl Personen je Haushalt](output/haushalte_anzahl_personen.ttl)
- [Anzahl der Kinder je Haushalt](output/haushalte_anzahl_kinder.ttl)
- [Wohngemeinschaft je Haushalt](output/haushalte_wohngemeinschaften.ttl)

Die RDF Data Cube Datenstruktur-Definitionen der Datasets ist in [`losdb-vocab.ttl`](priv/vocabs/losdb-vocab.ttl) zu finden.


## Generierung der Datasets

Anforderung: eine installierte [Elixir](https://elixir-lang.org/install.html)-Umgebung.

Installation der abhängigen Pakete mit:

```shell
$ mix deps.get
```

Damit können die Datasets mit dem folgenden Kommando in den `output`-Ordner generiert werden:

```shell
$ mix generate
```
