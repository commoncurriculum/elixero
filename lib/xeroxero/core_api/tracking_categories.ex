defmodule XeroXero.CoreApi.TrackingCategories do
  @api_type :core
  @resource "trackingcategories"
  @model_module XeroXero.CoreApi.Models.TrackingCategories
  @options_model_module XeroXero.CoreApi.Models.TrackingCategories.TrackingCategory.Options

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

  def create(client, categories_map) do
    XeroXero.CoreApi.Common.create(client, @resource, categories_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, categories_map) do
    XeroXero.CoreApi.Common.update(client, @resource, identifier, categories_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def delete(client, identifier) do
    XeroXero.CoreApi.Common.delete(client, @resource, identifier)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def add_option(client, identifier, options_map) do
    resource = @resource <> "/" <> identifier <> "/options"

    XeroXero.Private.create(client, resource, @api_type, options_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@options_model_module)
  end

  def update_option(client, category_identifier, option_identifier, options_map) do
    resource = @resource <> "/" <> category_identifier <> "/options/" <> option_identifier

    XeroXero.Private.update(client, resource, @api_type, options_map)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@options_model_module)
  end

  def delete_option(client, category_identifier, option_identifier) do
    resource = @resource <> "/" <> category_identifier <> "/options/" <> option_identifier

    XeroXero.Private.delete(client, resource, @api_type)
    |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(@options_model_module)
  end
end
