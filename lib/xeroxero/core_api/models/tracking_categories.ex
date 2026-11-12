defmodule XeroXero.CoreApi.Models.TrackingCategories do
    use Ecto.Schema
    import Ecto.Changeset
    
    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "trackingcategories" do
        embeds_many :TrackingCategories, XeroXero.CoreApi.Models.TrackingCategories.TrackingCategory
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:TrackingCategories)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:TrackingCategories => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:TrackingCategories)
        |> apply_changes
    end
end
