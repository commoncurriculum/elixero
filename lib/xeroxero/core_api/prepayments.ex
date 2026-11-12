defmodule XeroXero.CoreApi.Prepayments do
  @resource "prepayments"
  @model_module XeroXero.CoreApi.Models.Prepayments
  @allocations_model_module XeroXero.CoreApi.Models.Allocations

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

  def allocate_prepayment(client, identifier, allocations_map) do
    resource = @resource <> "/" <> identifier <> "/allocations"
    
    XeroXero.CoreApi.Common.create(client, resource, allocations_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@allocations_model_module)
  end
end
