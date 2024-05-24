defmodule Crawler.Task.Impl do
  require Logger
  @behaviour Crawler.Task.Behaviour

  @impl Crawler.Task.Behaviour
  def fetch(url) do
    with {:ok, body} <- Crawler.Process.crawl(url),
         {:ok, urls} <- Crawler.Process.parse(body),
         processed <- Crawler.Process.process_urls(urls, url) do
      Crawler.Cache.update_status(url, :success, %{processed_links: Enum.into(processed, [])})
      processed |> Enum.each(&Crawler.Runner.start/1)
    else
      {:error, :redirect, value} ->
        Crawler.Cache.update_status(url, :redirect, %{redirect_location: value})

        Crawler.Process.process_urls([value], url)
        |> Enum.each(&Crawler.Runner.start/1)

        :ok

      {:error, :unexpected_status, 404} ->
        Crawler.Cache.update_status(url, :not_found)
        :ok

      {:error, :unexpected_status, status_code} ->
        Crawler.Cache.update_status(url, :unexpected, %{unexpected_status_code: status_code})
        Logger.warning("Unhandled status code #{status_code} for #{url}")
        :ok

      {:error, "cannot transform bytes from binary to a valid UTF8 string"} ->
        Crawler.Cache.update_status(url, :binary)
        :ok

      {:error, :timeout} ->
        Crawler.Cache.update_status(url, :retry)
        :error

      err ->
        Crawler.Cache.update_status(url, :retry)
        Logger.error("Error while processing #{url}: #{inspect(err)}")
        :error
    end
  end
end
