defmodule JellyfinTools do
  require Logger

  @imdb_apikey "k_q3758gy3"

  @moduledoc """
  Documentation for `JellyfinTools`.
  """

  def shows(dir) do
    list_shows(dir)
    |> Enum.group_by(fn filename ->
      filename
      |> get_title()
    end)
    |> Map.to_list()
    |> Enum.each(fn {title, filenames} ->
      Logger.info("[#{__MODULE__}] IMDB search expression: '#{title}'")

      title
      |> String.downcase()
      |> search("SearchSeries")
      |> process_result(filenames, dir)

      Stream.timer(300) |> Stream.run()
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
    title = res["title"]
    year = res["description"] |> String.replace(~r/[0-9]{4}(.)/, "\\1")
    target = dir <> "#{title} (#{year}) [imdbid-#{id}]"

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
          Logger.error("[#{__MODULE__}] reason: #{inspect(reason)}")
          %{"results" => []}
      end

    case resp["results"] do
      nil ->
        nil

      results ->
        results
        |> Enum.fetch!(0)
    end
  end
end
