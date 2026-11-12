defmodule XeroXero.CoreApi.Models.Items do
    use Ecto.Schema
    import Ecto.Changeset
    
    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "items" do
        embeds_many :Items, XeroXero.CoreApi.Models.Items.Item
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:Items)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:Items => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:Items)
        |> apply_changes
    end
end
