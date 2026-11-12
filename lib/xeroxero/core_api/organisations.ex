defmodule XeroXero.CoreApi.Organisations do
  @resource "organisations"
  @model_module XeroXero.CoreApi.Models.Organisations

  def find(client) do
    XeroXero.CoreApi.Common.find(client, @resource)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
