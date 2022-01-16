defmodule Mix.Tasks.Shows do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @shortdoc "Runs the fetcher for IMDB"
  def run(_) do
    Mix.Task.run("app.start")
    
    JellyfinTools.shows()
  end
end