defmodule Crawler.Task.Behaviour do
  @callback fetch(binary()) :: :error | :ok
end
