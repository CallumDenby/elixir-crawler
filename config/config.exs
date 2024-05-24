import Config

config :crawler,
  init_url: "https://wordpress.com/",
  retries: 10

config :floki, :html_parser, Floki.HTMLParser.Html5ever

config :logger,
  level: :info
