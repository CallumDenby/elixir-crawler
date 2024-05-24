defmodule Crawler.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Crawler.Cache.Impl,
      {Task.Supervisor, name: Crawler.TaskSupervisor},
      {Task,
       fn ->
         Crawler.Runner.start(Application.get_env(:crawler, :init_url))
       end}
    ]

    options = [strategy: :one_for_one, name: Crawler.Supervisor]
    Supervisor.start_link(children, options)
  end
end
