defmodule XeroXero.CoreApi.InvoiceReminders do
  @resource "invoicereminders"
  @model_module XeroXero.CoreApi.Models.InvoiceReminders

  def settings(client) do
    resource = @resource <> "/settings"

    XeroXero.CoreApi.Common.find(client, resource)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
