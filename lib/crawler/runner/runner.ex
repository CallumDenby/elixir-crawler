defmodule Crawler.Runner do
  @behaviour Crawler.Runner.Behaviour

  @impl Crawler.Runner.Behaviour
  def start(url) do
    runner_impl().start(url)
  end

  @impl Crawler.Runner.Behaviour
  def is_last_task?() do
    runner_impl().is_last_task?()
  end

  defp runner_impl() do
    Application.get_env(:bound, :runner, Crawler.Runner.Impl)
  end
end
