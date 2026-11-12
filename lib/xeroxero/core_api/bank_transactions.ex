defmodule XeroXero.CoreApi.BankTransactions do
  @resource "banktransactions"
  @model_module XeroXero.CoreApi.Models.BankTransactions

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

  def create(client, bank_transactions_map) do
    XeroXero.CoreApi.Common.create(client, @resource, bank_transactions_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, bank_transactions_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, bank_transactions_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
