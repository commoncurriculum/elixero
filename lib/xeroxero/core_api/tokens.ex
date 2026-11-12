defmodule XeroXero.CoreApi.Tokens do
  @resource "/token"
  @model_module XeroXero.CoreApi.Models.Tokens.Token

  def refresh_token(refresh_token, client_id, client_secret) do
    url = XeroXero.Utils.Urls.token_url(@resource)
    data_map = URI.encode_query(%{"grant_type" => "refresh_token", "refresh_token" => refresh_token})
    headers = [{"Authorization", "Basic " <> Base.encode64(client_id <> ":" <> client_secret)},
               {"Content-Type", "application/x-www-form-urlencoded"}]

    url
    |> XeroXero.Utils.Http.post_token(headers, data_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
