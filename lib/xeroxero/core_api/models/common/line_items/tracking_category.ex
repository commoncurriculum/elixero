defmodule XeroXero.CoreApi.Models.Common.LineItems.TrackingCategory do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "trackingcategories" do
        field :TrackingCategoryID, Ecto.UUID
        field :Name, :string
        field :Option, :string
        field :TrackingOptionID, Ecto.UUID
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string  
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:TrackingCategoryID, :Name, :Option, :TrackingOptionID, :StatusAttributeString])
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
