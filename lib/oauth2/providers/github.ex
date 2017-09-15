defmodule OAuth2.Provider.GitHub do
  @moduledoc """
  OAuth2 GitHub Provider

  Based on:

      github.com/scrogson/oauth2
      github.com/ueberauth/ueberauth_github

  Add `client_id` and `client_secret` to your configuration:

      config :oauth2_github, OAuth2.Provider.GitHub,
        client_id: System.get_env("GITHUB_APP_ID"),
        client_secret: System.get_env("GITHUB_APP_SECRET")
  """
  use OAuth2.Strategy

  @client_defaults [
    strategy: __MODULE__,
    site: "https://api.github.com",
    authorize_url: "https://github.com/login/oauth/authorize",
    token_url: "https://github.com/login/oauth/access_token"
  ]

  @doc """
  Construct a client for requests to GitHub.
  This will be setup automatically for you in `Ueberauth.Strategy.GitHub`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    opts =
      @client_defaults
      |> Keyword.merge(config())
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Returns an OAuth2.Client with token.
  """
  def get_token!(params \\ [], opts \\ []) do
    headers = Keyword.get(opts, :headers, [])
    options = Keyword.get(opts, :options, [])

    opts
    |> client
    |> OAuth2.Client.get_token!(params, headers, options)
  end

  @doc """
  Returns user information only.
  To return token before querying for user, see `get_user/3`
  """
  def get_user!(params \\ [], opts \\ []) do
    OAuth2.Provider.GitHub.get_token!(params, opts)
    |> get_user()
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  @doc """
  Returns user information from GitHub's `/user` and `/user/emails` endpoints using the access_token.
  """
  def get_user(client) do
    with {:ok, user} <- get_data(client, "/user"),
         {:ok, emails} <- get_data(client, "/user/emails") do
      {:ok, Map.put(user, "emails", emails)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_data(client, endpoint) do
    case OAuth2.Client.get(client, endpoint) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        {:error, "Unauthorized"}
      {:ok, %OAuth2.Response{status_code: status_code, body: body}}
        when status_code in 200..399 ->
        {:ok, body}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # Helpers

  defp config do
    Application.fetch_env!(:oauth2_github, OAuth2.Provider.GitHub)
    |> check_config_key_exists(:client_id)
    |> check_config_key_exists(:client_secret)
  end

  defp get_config(key) do
    Keyword.get(config(), key)
  end

  defp check_config_key_exists(config, key) when is_list(config) do
    unless Keyword.has_key?(config, key) do
      raise "#{inspect (key)} missing from config :oauth2_github, OAuth2.Provider.GitHub"
    end
    config
  end
  defp check_config_key_exists(_, _) do
    raise "Config :oauth2_github, OAuth2.Provider.GitHub is not a keyword list, as expected"
  end
end
