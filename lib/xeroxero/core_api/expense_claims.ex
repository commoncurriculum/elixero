defmodule XeroXero.CoreApi.ExpenseClaims do
  @resource "expenseclaims"
  @model_module XeroXero.CoreApi.Models.ExpenseClaims

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

  def create(client, expense_claims_map) do
    XeroXero.CoreApi.Common.create(client, @resource, expense_claims_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, expense_claims_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, expense_claims_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
