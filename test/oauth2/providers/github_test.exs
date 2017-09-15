defmodule OAuth2.Provider.GitHubTest do

  use ExUnit.Case, async: true
  use Plug.Test

  import OAuth2.TestHelpers

  alias OAuth2.Client
  alias OAuth2.AccessToken
  alias OAuth2.Provider.GitHub

  setup do
    server = Bypass.open
    client = build_client(strategy: GitHub, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "client created with default values" do
    result = GitHub.client
    assert result.authorize_url == "https://github.com/login/oauth/authorize"
  end

  test "client takes optional values" do
    result = GitHub.client(authorize_url: "new")
    assert result.authorize_url == "new"
  end

  test "authorize_url!" do
    result = GitHub.authorize_url!([], [])
    assert Regex.match?(~r/github.com/, result)
  end

  test "authorize_url", %{client: client, server: server} do
    client = GitHub.authorize_url(client, [])
    assert "http://localhost:#{server.port}" == client.site

    assert client.params["client_id"] == client.client_id
    assert client.params["redirect_uri"] == client.redirect_uri
    assert client.params["response_type"] == "code"
  end

  test "get_token throws and error if there is no 'code' param" do
    assert_raise OAuth2.Error, ~r/Missing required key/, fn ->
      GitHub.get_token(build_client(), [], [])
    end
  end
end
