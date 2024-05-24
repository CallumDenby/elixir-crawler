defmodule Crawler.Process do
  @moduledoc """
  Interface for the crawler logic.
  """

  @behaviour Crawler.Process.Behaviour

  @impl Crawler.Process.Behaviour
  def crawl(url) do
    process_impl().crawl(url)
  end

  @impl Crawler.Process.Behaviour
  def parse(body) do
    process_impl().parse(body)
  end

  @impl Crawler.Process.Behaviour
  def process_urls(urls, base) do
    process_impl().process_urls(urls, base)
  end

  defp process_impl() do
    Application.get_env(:bound, :process, Crawler.Process.Impl)
  end
end
