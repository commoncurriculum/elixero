defmodule XeroXero.Utils.Urls do

  #api_types
  @core_api "api.xro/2.0/"
  @payroll_api "payroll.xro/1.0/"
  @files_api "files.xro/1.0/"
  @assets_api "assets.xro/1.0/"

  def request_token do
    base_url() <> "oauth/RequestToken"
  end

  def token_url(resource) do
    Application.get_env(:xeroxero, :token_url, "https://identity.xero.com/connect") <> resource
  end

  def authorise(oauth_token) do
    base_url() <> "oauth/Authorize?oauth_token=" <> oauth_token
  end

  def access_token do
    base_url() <> "oauth/AccessToken"
  end

  def api(resource, api_type) do
    api =
      case(api_type) do
        :core -> @core_api
        :payroll -> @payroll_api
        :files -> @files_api
        :assets -> @assets_api
      end

    base_url() <> api <> resource
  end

  def append_query_filters(url, query_filters) do
    query_param_string = Enum.map_join query_filters, "&", fn({key, value}) ->
      encoded_value = URI.encode(value, &URI.char_unreserved?(&1))
      encoded_value = String.replace(encoded_value, "+", "%20") # Spaces must be %20 not +
      key <> "=" <> encoded_value
    end

    url <> "?" <> query_param_string
  end

  defp base_url do
    Application.get_env(:xeroxero, :base_url, "https://api.xero.com/")
  end
end
