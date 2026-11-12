defmodule XeroXero.CoreApi.ContactGroups do
  @api_type :core
  @resource "contactgroups"
  @model_module XeroXero.CoreApi.Models.ContactGroups
  @contacts_model_module XeroXero.CoreApi.Models.Contacts

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

  def create(client, contact_groups_map) do
    XeroXero.CoreApi.Common.create(client, @resource, contact_groups_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, contact_groups_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, contact_groups_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def add_to_group(client, identifier, contacts_map) do
    resource = @resource <> "/" <> identifier <> "/contacts"

    case client.app_type do
      :private -> XeroXero.Private.create(client, resource, @api_type, contacts_map)
      :public -> XeroXero.Public.create(client.access_token, resource, @api_type, contacts_map)
      :partner -> XeroXero.Partner.create(client.access_token, resource, @api_type, contacts_map)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@contacts_model_module)
  end

  def remove_contact(client, contact_group_identifier, contact_identifier) do
    resource = @resource <> "/" <> contact_group_identifier <> "/contacts/" <> contact_identifier

    case client.app_type do
      :private -> XeroXero.Private.delete(client.access_token, resource, @api_type)
      :public -> XeroXero.Public.delete(client.access_token, resource, @api_type)
      :partner -> XeroXero.Partner.delete(client.access_token, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def remove_all_contacts(client, identifier) do
    resource = @resource <> "/" <> identifier <> "/contacts"

    case client.app_type do
      :private -> XeroXero.Private.delete(client.access_token, resource, @api_type)
      :public -> XeroXero.Public.delete(client.access_token, resource, @api_type)
      :partner -> XeroXero.Partner.delete(client.access_token, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
