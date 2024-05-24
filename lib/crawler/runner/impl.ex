defmodule Crawler.Runner.Impl do
  require Logger
  use Retry

  @behaviour Crawler.Runner.Behaviour

  def is_last_task?() do
    %{active: active} = Supervisor.count_children(Crawler.TaskSupervisor)

    # Logger.info("Remaining active: #{active}")

    if active <= 1 do
      Logger.info("Finished")
    end

    active <= 1
  end

  def start(url) do
    retries = Application.get_env(:crawler, :retries, 3)

    with status when status in [nil, :retry] <- Crawler.Cache.get_status(url) do
      Crawler.Cache.update_status(url, :pending)

      Task.Supervisor.start_child(Crawler.TaskSupervisor, fn ->
        retry with: constant_backoff(100) |> Stream.take(retries) do
          Crawler.Task.fetch(url)
        else
          error ->
            Logger.error("Failed with #{retries} retries #{url}")
            Crawler.Cache.update_status(url, :failed)
            is_last_task?()
        after
          _ ->
            is_last_task?()
        end
      end)
    end
  end
end
