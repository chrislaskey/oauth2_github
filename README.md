# OAuth2 GitHub

> A GitHub OAuth2 Provider for Elixir

[![Build Status](https://travis-ci.org/chrislaskey/oauth2_github.svg?branch=master)](https://travis-ci.org/chrislaskey/oauth2_github)

OAuth2 GitHub is convenience library built on top of [`oauth2`](https://hex.pm/packages/oauth2). It adds GitHub specific functions to interact with GitHub endpoints using OAuth2.

## Installation

```elixir
# mix.exs

def application do
  # Add the application to your list of applications.
  # This will ensure that it will be included in a release.
  [applications: [:logger, :oauth2_github]]
end

defp deps do
  # Add the dependency
  [{:oauth2_github, "~> 0.1"}]
end
```

## Authenticating a User

> For an easy-to-use, end-to-end solution enabling users to log in with GitHub see [`ueberauth/ueberauth_github`](https://github.com/ueberauth/ueberauth_github)

One common use-case is authenticating a user's identify. The `get_user!` function wraps two actions into one - exchanging the callback code for a short-lived access token and using the access token to return user data:

```elixir
alias OAuth2.Provider.GitHub

GitHub.get_user!([code: "<callback-code>"], [redirect_uri: "..."])
```

When successful, it returns the user data:

```elixir
{:ok, %{"collaborators" => 0, "two_factor_authentication" => true, "company" => nil, "bio" => nil, "following" => 0, "followers_url" => "https://api.github.com/users/example/followers", "public_gists" => 0, "id" => 1, "avatar_url" => "https://avatars1.githubusercontent.com/u/1?v=4", "events_url" => "https://api.github.com/users/example/events{/privacy}", "starred_url" => "https://api.github.com/users/example/starred{/owner}{/repo}", "emails" => [%{"email" => "chris.laskey@gmail.com", "primary" => true, "verified" => true, "visibility" => "public"}, %{"email" => "1@example.com", "primary" => false, "verified" => true, "visibility" => nil}, %{"email" => "2@example.com", "primary" => false, "verified" => true, "visibility" => nil}, %{"email" => "3@example.com", "primary" => false, "verified" => false, "visibility" => nil}], "private_gists" => 0, "blog" => "http://example.com", "subscriptions_url" => "https://api.github.com/users/example/subscriptions", "type" => "User", "disk_usage" => 517040, "site_admin" => false, "owned_private_repos" => 0, "public_repos" => 75, "location" => "Moon", "hireable" => nil, "created_at" => "2016-10-30T22:30:53Z", "name" => "John Smith", "organizations_url" => "https://api.github.com/users/example/orgs", "gists_url" => "https://api.github.com/users/example/gists{/gist_id}", "following_url" => "https://api.github.com/users/example/following{/other_user}", "url" => "https://api.github.com/users/example", "email" => "contact@example.com", "login" => "example", "html_url" => "https://github.com/example", "gravatar_id" => "", "received_events_url" => "https://api.github.com/users/example/received_events", "repos_url" => "https://api.github.com/users/example/repos", "plan" => %{"collaborators" => 0, "name" => "free", "private_repos" => 0, "space" => 32976562499}, "followers" => 0, "updated_at" => "2017-01-03T01:00:40Z", "total_private_repos" => 0}}
```

## Returning an Access Token

A valid access token can be used to make multiple requests to GitHub. The callback code can be exchanged for an access token using `get_token!`:

```elixir
alias OAuth2.Provider.GitHub

client = GitHub.get_token!([code: "<callback-code>"], [redirect_uri: "..."])
```

When successful, it will return a valid `OAuth2.Client`:

```
%OAuth2.Client{authorize_url: "https://github.com/login/oauth/authorize", client_id: "<...>", client_secret: "<...>", headers: [], params: %{}, redirect_uri: "http://localhost:3000/login/github/callback", ref: nil, request_opts: [], site: "https://api.github.com", strategy: OAuth2.Provider.GitHub, token: %OAuth2.AccessToken{access_token: "38aac97adc9722c62272bf521a38e4f0cd7423fa", expires_at: nil, other_params: %{"scope" => "user"}, refresh_token: nil, token_type: "Bearer"}, token_method: :post, token_url: "https://github.com/login/oauth/access_token"}
```

**Note:** The access token is kept under the client's `token` key.

## Using a Valid Client

A valid client with an access token can then be passed into endpoint specific functions. For example, to return user data using a `client` with a valid access token:

```elixir
alias OAuth2.Provider.GitHub

{:ok, user} = GitHub.get_user(client)
```

When successful, it will return the same user information:

```elixir
%{"collaborators" => 0, "two_factor_authentication" => true, "company" => nil, "bio" => nil, "following" => 0, "followers_url" => "https://api.github.com/users/example/followers", "public_gists" => 0, "id" => 1, "avatar_url" => "https://avatars1.githubusercontent.com/u/1?v=4", "events_url" => "https://api.github.com/users/example/events{/privacy}", "starred_url" => "https://api.github.com/users/example/starred{/owner}{/repo}", "emails" => [%{"email" => "chris.laskey@gmail.com", "primary" => true, "verified" => true, "visibility" => "public"}, %{"email" => "1@example.com", "primary" => false, "verified" => true, "visibility" => nil}, %{"email" => "2@example.com", "primary" => false, "verified" => true, "visibility" => nil}, %{"email" => "3@example.com", "primary" => false, "verified" => false, "visibility" => nil}], "private_gists" => 0, "blog" => "http://example.com", "subscriptions_url" => "https://api.github.com/users/example/subscriptions", "type" => "User", "disk_usage" => 517040, "site_admin" => false, "owned_private_repos" => 0, "public_repos" => 75, "location" => "Moon", "hireable" => nil, "created_at" => "2016-10-30T22:30:53Z", "name" => "John Smith", "organizations_url" => "https://api.github.com/users/example/orgs", "gists_url" => "https://api.github.com/users/example/gists{/gist_id}", "following_url" => "https://api.github.com/users/example/following{/other_user}", "url" => "https://api.github.com/users/example", "email" => "contact@example.com", "login" => "example", "html_url" => "https://github.com/example", "gravatar_id" => "", "received_events_url" => "https://api.github.com/users/example/received_events", "repos_url" => "https://api.github.com/users/example/repos", "plan" => %{"collaborators" => 0, "name" => "free", "private_repos" => 0, "space" => 32976562499}, "followers" => 0, "updated_at" => "2017-01-03T01:00:40Z", "total_private_repos" => 0}
```
