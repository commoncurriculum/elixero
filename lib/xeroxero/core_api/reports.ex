defmodule XeroXero.CoreApi.Reports do
  @api_type :core
  @resource "reports"
  @model_module XeroXero.CoreApi.Models.Reports

  def find(client) do
    XeroXero.CoreApi.Common.find(client, @resource)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def named(client, name) do
    resource = @resource <> "/" <> name

    case client.app_type do
      :private -> XeroXero.Private.find(client, resource, @api_type)
      :public -> XeroXero.Public.find(client, resource, @api_type)
      :partner -> XeroXero.Partner.find(client, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def named(client, name, filter) do
    resource = @resource <> "/" <> name <> "?" <> filter

    case client.app_type do
      :private -> XeroXero.Private.find(client, resource, @api_type)
      :public -> XeroXero.Public.find(client, resource, @api_type)
      :partner -> XeroXero.Partner.find(client, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def individual_report(client, identifier) do
    resource = @resource <> "/" <> identifier

    case client.app_type do
      :private -> XeroXero.Private.find(client, resource, @api_type)
      :public -> XeroXero.Public.find(client, resource, @api_type)
      :partner -> XeroXero.Partner.find(client, resource, @api_type)
    end
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
