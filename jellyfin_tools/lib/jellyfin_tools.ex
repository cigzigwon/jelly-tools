defmodule JellyfinTools do

  @imdb_apikey "k_q3758gy3"

  @moduledoc """
  Documentation for `JellyfinTools`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> JellyfinTools.hello()
      :world

  """
  def hello do
    :world
  end

  def list_shared() do
    File.ls!("/root/media/")
  end

  def get_title(filename) do
    String.split(filename, ~r/[S][0-9]{2}[E][0-9]{2}/)
    |> Enum.fetch!(0)
    |> String.replace(".", " ")
    |> String.trim()
  end

  def search_series(name) do
    url = "https://imdb-api.com/en/API/SearchSeries/#{@imdb_apikey}/#{name}"
      |> URI.encode()

    resp =
      case HTTPoison.get(url) do
        {:ok, resp} ->
          # IO.puts resp.body
          Poison.decode!(resp.body)
        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect reason
      end

    if resp["results"] |> length() do
      top = resp["results"] |> Enum.fetch!(0)
      top["id"]
    end
  end
end
