# XeroXero

## Usage instructions

XeroXero calls the Xero API with an OAuth 2.0 access token. Create an app in the [Xero developer portal](https://developer.xero.com/app/manage) and configure its client id and secret:

```
config :xeroxero,
  client_id: "your_client_id",
  client_secret: "your_client_secret"
```

`base_url` (default `"https://api.xero.com/"`) and `token_url` (default `"https://identity.xero.com/connect"`) point the library at another server, such as a test server.

1. Exchange a refresh token for an access token
  ```
  token = XeroXero.CoreApi.Tokens.refresh_token(refresh_token, client_id, client_secret)
  ```

2. Create a client for the organisation (tenant) you're calling
  ```
  client = %{XeroXero.create_client(token) | xero_tenant_id: "your_tenant_id"}
  ```

3. Use the client when calling the Xero API
  ```
  XeroXero.CoreApi.Invoices.find client
  ```

## Use of filter functions

Some endpoints allow various filter methods when retrieving information from the Xero API.
All filtering, with the exception of if-modified-since, is performed via query parameters. If-modified-since is done via a header.

When using filtering, a map outlining what filtering you want needs to be supplied.

Below is an example on how to do this when you want to retrieve all DRAFT, ACCREC invoices, ordered by Date desc, modified since the start of 2017:

```
filter = %{:query_filters => [{"where", "Status==\"DRAFT\" AND Type==\"ACCREC\""}, {"orderby", "Date desc"}], :modified_since => "2017-01-01" }

XeroXero.CoreApi.Invoices.filter client, filter
```

You do not need to supply both :query_filters and :modified_since if you only want to filter by one of them.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `xeroxero` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:xeroxero, github: "commoncurriculum/elixero"}]
    end
    ```

  2. Ensure `elixero` is started before your application:

    ```elixir
    def application do
      [applications: [:xeroxero]]
    end
    ```
