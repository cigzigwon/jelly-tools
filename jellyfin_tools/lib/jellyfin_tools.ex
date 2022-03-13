defmodule JellyfinTools do

  require Logger

  @imdb_apikey "k_q3758gy3"
  @shows_dir "/root/media/shows/"

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

  def shows() do
    list_shows()
    |> Enum.group_by(fn filename ->
      filename
      |> get_title()
    end)
    |> Map.to_list()
    |> Enum.each(fn {title, filenames} ->
      Logger.info("[JellyfinTools] IMDB search expression: '#{title}'")

      title
      |> search()
      |> process_result(filenames)

      Process.sleep(150)
    end)

    Logger.info("[JellyfinTools] organized shows complete!")

    :ok
  end

  def process_result(nil, _) do
    :ok
  end

  def process_result(res, filenames) do
    id = res["id"]
    desc = res["description"]
    title = res["title"]
    target = @shows_dir <> "#{title} #{desc} [imdbid-#{id}]"

    if not File.exists?(target) do
      File.mkdir!(target)
      Logger.info("[JellyfinTools] created new directory in: #{target}")
    end

    filenames
    |> Enum.each(&(File.rename!(@shows_dir <> &1, target <> "/" <> &1)))
  end

  def list_shows() do
    File.ls!(@shows_dir)
    |> Enum.filter(&(&1 |> String.contains?(".mp4")))
  end

  def get_title(filename) do
    String.split(filename, ~r/[sS][0-9]{2}[eE][0-9]{2}/)
    |> Enum.fetch!(0)
    |> String.replace(".", " ")
    |> String.trim()
  end

  def search(name) do
    url =
      "https://imdb-api.com/en/API/Search/#{@imdb_apikey}/#{name}"
      |> URI.encode()

    resp =
      case HTTPoison.get(url, [], recv_timeout: 30_000) do
        {:ok, resp} ->
          Poison.decode!(resp.body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect(reason)
          %{"results" => []}
      end

    if resp["results"] |> length() > 0 do
      resp["results"] |> Enum.fetch!(0)
    else
      :noop
    end
  end
end
