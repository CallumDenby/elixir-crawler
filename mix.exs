defmodule Crawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :crawler,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An Elixir Web Crawler",
      package: package(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Crawler.Application, []},
      extra_applications: [:logger, :retry]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.35.3"},
      {:html5ever, "~> 0.15.0"},
      {:httpoison, "~> 2.2"},
      {:poison, "~> 5.0"},
      {:retry, "~> 0.18"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:hammox, "~> 0.7", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
