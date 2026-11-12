defmodule XeroXero.CoreApi.Invoices do
  @api_type :core
  @resource "invoices"
  @model_module XeroXero.CoreApi.Models.Invoices
  @online_invoices_model_module XeroXero.CoreApi.Models.OnlineInvoices

  def find(client) do
    XeroXero.CoreApi.Common.find(client, @resource)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def find(client, identifier) do
    XeroXero.CoreApi.Common.find(client, @resource, identifier)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def filter(client, filter) do
    XeroXero.CoreApi.Common.filter(client, @resource, filter)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def create(client, invoices_map) do
    XeroXero.CoreApi.Common.create(client, @resource, invoices_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, invoices_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, invoices_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def email(client, identifier) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier <> "/Email", %{})
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def online_invoice_url(client, identifier) do
    resource = @resource <> "/" <> identifier <> "/OnlineInvoice"

    case client.app_type do
      :private -> XeroXero.Private.find(client, resource, @api_type)
      :public -> XeroXero.Public.find(client, resource, @api_type)
      :partner -> XeroXero.Partner.find(client, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@online_invoices_model_module)
  end
end
