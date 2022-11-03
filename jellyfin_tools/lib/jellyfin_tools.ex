defmodule JellyfinTools do
  require Logger

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

  def shows(dir) do
    list_shows(dir)
    |> Enum.group_by(fn filename ->
      filename
      |> get_title()
    end)
    |> Map.to_list()
    |> Enum.each(fn {title, filenames} ->
      title = title |> String.downcase()

      Logger.info("[#{__MODULE__}] IMDB search expression: '#{title}'")

      title
      |> search("SearchSeries")
      |> process_result(filenames, dir)

      Process.sleep(150)
    end)

    Logger.info("[#{__MODULE__}] organized shows complete!")

    :ok
  end

  def process_result(nil, _, _) do
    Logger.info("[#{__MODULE__}] no results returned in search")

    :ok
  end

  def process_result(res, filenames, dir) do
    id = res["id"]
    desc = res["description"]
    title = res["title"]
    target = dir <> "#{title} #{desc} [imdbid-#{id}]"

    if not File.exists?(target) do
      File.mkdir!(target)
      Logger.info("[#{__MODULE__}] created new directory in: #{target}")
    end

    filenames
    |> Enum.each(&File.rename!(dir <> &1, target <> "/" <> &1))
  end

  def list_shows(dir) do
    File.ls!(dir)
    |> Enum.filter(&(&1 |> String.contains?(".mp4")))
  end

  def get_title(filename) do
    filename
    |> String.replace(~r/(\d+)x(\d+)/, "S\\1E\\2")
    |> String.split(~r/[sS]\d+[eE]\d+/)
    |> Enum.fetch!(0)
    |> String.replace(".", " ")
    |> String.trim()
  end

  def search(name, type) do
    url =
      "https://imdb-api.com/en/API/#{type}/#{@imdb_apikey}/#{name}"
      |> URI.encode()

    resp =
      case HTTPoison.get(url, [], recv_timeout: 30_000) do
        {:ok, resp} ->
          Poison.decode!(resp.body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect(reason)
          %{"results" => []}
      end

    case resp["results"] do
      nil -> nil

      results ->
        results
        |> Enum.find(fn %{"title" => title} = _ ->
          title
          |> String.downcase()
          |> String.contains?(name |> String.downcase() |> String.split(" "))
        end)
    end
  end
end
