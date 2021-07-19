defmodule Mix.Tasks.Generate do
  use Mix.Task

  alias LOSDB.Dataset.{Population, Household}

  @shortdoc "Generate the LOSDB datasets"
  def run(_) do
    Population.extract_bezirke()
    Population.extract_dataset(write: true)
    Household.extract_datasets()
  end
end
