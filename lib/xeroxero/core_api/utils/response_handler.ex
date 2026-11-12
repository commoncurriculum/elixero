defmodule XeroXero.CoreApi.Utils.ResponseHandler do
    def handle_response(response, expected_model) do
        case response do
            %{:status => 200}  -> transform response.body, expected_model, :ok
            %{:status => 204}  -> %{:status_code => 204, :message => "No Content"}
            %{:status => 400}  -> transform response.body, expected_model, :bad_request
            %{:status => 500}  -> transform_to_api_exception response.body
            _                  -> %{:status_code => response.status, :message => URI.decode_query(response.body)}
        end
    end

    defp transform(json, module, :ok) do
        case (Jason.decode json, keys: :atoms) do
            {:ok, data} -> module.from_map data
            _ -> "Something went wrong transforming to module"
        end
    end

    defp transform(json, module, :bad_request) do
        case (Jason.decode json, keys: :atoms) do
            {:ok, %{:ErrorNumber => 10} = data} -> module.from_validation_exception data
            {:ok, data}                         -> data
            _                                   -> "Something went wrong transforming to module"
        end
    end

    defp transform_to_api_exception(json) do
        case (Jason.decode json, keys: :atoms) do
            {:ok, data} -> XeroXero.CoreApi.Models.Exceptions.ApiException.from_map data
            _ -> "Something went wrong transforming to module"
        end
    end
end
