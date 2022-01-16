defmodule JellyfinToolsTest do
  use ExUnit.Case
  doctest JellyfinTools

  test "greets the world" do
    assert JellyfinTools.hello() == :world
  end
end
