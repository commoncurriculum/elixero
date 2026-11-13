defmodule XeroXero.CoreApi.Common do
  @api_type :core

  def find(client, resource) do
    XeroXero.Private.find(client, resource, @api_type)
  end

  def find(client, resource,  identifier) do
    resource = resource <> "/" <> identifier

    find(client, resource)
  end

  def filter(client, resource, filter) do
    query_filters = filter[:query_filters]

    extra_headers =
      unless filter[:modified_since] == nil do
        [ {"if-modified-since", filter[:modified_since]} ]
      else
        []
      end

    XeroXero.Private.find(client, resource, @api_type, query_filters, extra_headers)
  end

  def create(client, resource, object_map) do
    XeroXero.Private.create(client, resource, @api_type, object_map)
  end

  def update(client, resource, identifier, object_map) do
    resource = resource <> "/" <> identifier

    XeroXero.Private.update(client, resource, @api_type, object_map)
  end

  def delete(client, resource, identifier) do
    resource = resource <> "/" <> identifier

    XeroXero.Private.delete(client, resource, @api_type)
  end
end
