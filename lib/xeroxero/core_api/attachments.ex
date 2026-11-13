defmodule XeroXero.CoreApi.Attachments do
  @api_type :core
  @resource "attachments"
  @model_module XeroXero.CoreApi.Models.Attachments

  def find(client, endpoint, identifier) do
    resource = endpoint <> "/" <> identifier <> "/" <> @resource

    XeroXero.CoreApi.Common.find(client, resource)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def find(client, endpoint, identifier, filename) do
    resource = endpoint <> "/" <> identifier <> "/" <> @resource <> "/" <> filename

    response = XeroXero.CoreApi.Common.find(client, resource)
    %{"data" => response.body, "http_status_code" => response.status}
  end

  def upload_attachment(client, endpoint, identifier, filename, file_path, include_online) do
    resource = endpoint <> "/" <> identifier <> "/" <> @resource

    case client.app_type do
      :private -> XeroXero.Private.upload_attachment(client, resource, @api_type, file_path, filename, include_online)
      :public -> XeroXero.Public.upload_attachment(client.access_token, resource, @api_type, file_path, filename, include_online)
      :partner -> XeroXero.Partner.upload_attachment(client.access_token, resource, @api_type, file_path, filename, include_online)
    end |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)

  end
end
