defmodule XeroXero.FilesApi.Files do
  @resource "files"
  @api_type :files

  def upload(client, path_to_file, name) do
    XeroXero.Private.upload_multipart(client, @resource, @api_type, path_to_file, name)
  end
end
