defmodule Crawler.Task do
  @behaviour Crawler.Task.Behaviour

  @impl Crawler.Task.Behaviour
  def fetch(url) do
    task_impl().fetch(url)
  end

  defp task_impl() do
    Application.get_env(:bound, :task, Crawler.Task.Impl)
  end
end
