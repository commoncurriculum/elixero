defmodule XeroXero.CoreApi.Contacts do
  @resource "contacts"
  @model_module XeroXero.CoreApi.Models.Contacts

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

  def create(client, contacts_map) do
    XeroXero.CoreApi.Common.create(client, @resource, contacts_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, contacts_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, contacts_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
