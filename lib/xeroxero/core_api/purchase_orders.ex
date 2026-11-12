defmodule XeroXero.CoreApi.PurchaseOrders do
  @resource "purchaseorders"
  @model_module XeroXero.CoreApi.Models.PurchaseOrders

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

  def create(client, purchase_orders_map) do
    XeroXero.CoreApi.Common.create(client, @resource, purchase_orders_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, purchase_orders_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, purchase_orders_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
