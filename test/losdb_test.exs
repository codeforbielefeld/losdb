defmodule LOSDBTest do
  use ExUnit.Case
  doctest LOSDB

  test "greets the world" do
    assert LOSDB.hello() == :world
  end
end
