defmodule XeroXero.CoreApi.CreditNotes do
  @resource "creditnotes"
  @model_module XeroXero.CoreApi.Models.CreditNotes
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

  def create(client, credit_notes_map) do
    XeroXero.CoreApi.Common.create(client, @resource, credit_notes_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, credit_notes_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, credit_notes_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def allocate_credit_note(client, identifier, allocations_map) do
    resource = @resource <> "/" <> identifier <> "/allocations"
    XeroXero.CoreApi.Common.create(client, resource, allocations_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@allocations_model_module)
  end
end
