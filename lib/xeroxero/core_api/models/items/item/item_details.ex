defmodule XeroXero.CoreApi.Models.Items.Item.ItemDetails do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "itemdetails" do
        field :UnitPrice, :decimal
        field :AccountCode, :string
        field :TaxType, :string
        field :UpdatedDateUTC, :string
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string   
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:UnitPrice, :AccountCode, :TaxType, :UpdatedDateUTC, :StatusAttributeString])
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
