defmodule XeroXero.FilesApi.Files do
  @resource "files"
  @api_type :files

  def upload(client, path_to_file, name) do
    case(Application.get_env(:xeroxero, :app_type)) do
      :private -> XeroXero.Private.upload_multipart(client.access_token, @resource, @api_type, path_to_file, name)
      :public -> XeroXero.Public.upload_multipart(client.access_token, @resource, @api_type, path_to_file, name)
      :partner -> XeroXero.Partner.upload_multipart(client.access_token, @resource, @api_type, path_to_file, name)
    end
  end
end
