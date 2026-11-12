defmodule XeroXero.CoreApi.TaxRates do
  @resource "taxrates"
  @model_module XeroXero.CoreApi.Models.TaxRates

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

  def create(client, tax_rates_map) do
    XeroXero.CoreApi.Common.create(client, @resource, tax_rates_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, tax_rates_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, tax_rates_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
