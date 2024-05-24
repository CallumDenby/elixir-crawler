defmodule Crawler.Cache do
  def get_status(url) when is_binary(url) do
    cache_impl().get_status(url)
  end

  def update_status(url, status) do
    cache_impl().update_status(url, status)
  end

  def update_status(url, status, meta) do
    cache_impl().update_status(url, status, meta)
  end

  defp cache_impl() do
    Application.get_env(:bound, :cache, Crawler.Cache.Impl)
  end
end
