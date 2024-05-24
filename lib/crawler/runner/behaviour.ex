defmodule Crawler.Runner.Behaviour do
  @callback start(binary()) :: any()

  @callback is_last_task?() :: boolean()
end
