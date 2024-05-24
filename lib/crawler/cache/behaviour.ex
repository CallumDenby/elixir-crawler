defmodule Crawler.Cache.Behaviour do
  @callback get_status(binary()) :: atom()

  @callback update_status(binary(), atom()) :: any()

  @callback update_status(binary(), atom(), map()) :: any()
end
