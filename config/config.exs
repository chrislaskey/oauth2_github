use Mix.Config

config :logger, level: :info

config :oauth2_github, OAuth2.Provider.GitHub,
  client_id: System.get_env("GITHUB_APP_ID"),
  client_secret: System.get_env("GITHUB_APP_SECRET")
