Application.load(:crawler)

for app <- Application.spec(:crawler, :applications) do
  Application.ensure_all_started(app)
end

[
  {:runner, RunnerBehaviourMock, Crawler.Runner.Behaviour},
  {:task, TaskBehaviourMock, Crawler.Task.Behaviour},
  {:process, ProcessBehaviourMock, Crawler.Process.Behaviour},
  {:cache, CacheBehaviourMock, Crawler.Cache.Behaviour},
  {:http_client, HttpBehaviourMock, HTTPoison.Base}
]
|> Enum.each(fn {atom, mock, mod} ->
  Hammox.defmock(mock, for: mod)
  Application.put_env(:bound, atom, mock)
end)

ExUnit.start(capture_log: true)
