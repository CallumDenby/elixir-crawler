defmodule Crawler.Cache.Impl do
  require Logger
  use GenServer

  @behaviour Crawler.Cache.Behaviour

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: Crawler.Cache.Impl.Server)
  end

  def get() do
    GenServer.call(Crawler.Cache.Impl.Server, {:get})
  end

  @impl Crawler.Cache.Behaviour
  def get_status(url) do
    GenServer.call(Crawler.Cache.Impl.Server, {:get, url})
  end

  @impl Crawler.Cache.Behaviour
  def update_status(url, status) do
    update_status(url, status, %{})
  end

  @impl Crawler.Cache.Behaviour
  def update_status(url, status, meta) do
    GenServer.cast(Crawler.Cache.Impl.Server, {:update, url, status, meta})
  end

  def export(file) do
    encoded = get() |> Poison.encode!(pretty: true)
    File.write(file, encoded)
  end

  # Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, url}, _from, state) do
    {:reply, Map.get(state, url, %{status: nil}).status, state}
  end

  @impl true
  def handle_cast({:update, url, status, meta}, state) do
    if :success == status,
      do: Logger.info("Retrieved #{url} with links #{inspect(meta.processed_links)}")

    {:noreply,
     Map.update(state, url, %{status: status, meta: meta, history: []}, fn val ->
       %{status: status, meta: Map.merge(meta, val.meta), history: [val.status | val.history]}
     end)}
  end
end
