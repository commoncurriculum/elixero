defmodule XeroXero.CoreApi.Models.ManualJournals.ManualJournal.JournalLine do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "journallines" do
        field :Description, :string
        field :LineAmount, :decimal
        field :AccountCode, :string
        field :TaxType, :string
        field :TaxAmount, :string        
        embeds_many :Tracking, XeroXero.CoreApi.Models.Common.LineItems.TrackingCategory
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string        
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:Description, :LineAmount, :AccountCode, :TaxType, :TaxAmount, :StatusAttributeString])
        |> cast_embed(:Tracking)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
