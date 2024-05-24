defmodule Crawler.Process.Behaviour do
  @callback crawl(binary()) ::
              {:error, any()} | {:ok, any()} | {:error, :redirect | :unexpected_status, any()}

  @callback parse(binary()) :: {:error, binary()} | {:ok, list()}

  @callback process_urls([binary()], binary()) :: any()
end
