defmodule XeroXero.CoreApi.Models.ManualJournals.ManualJournal do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :ManualJournalID,
        :Date,
        :Status,
        :LineAmountTypes,
        :Url,
        :ShowOnCashBasisReports,
        :Narration,
        :HasAttachments,
        :UpdatedDateUTC,
        :StatusAttributeString
    ]

    schema "manualjournals" do
        field :ManualJournalID, Ecto.UUID
        field :Date, :string
        field :Status, :string
        field :LineAmountTypes, :string
        field :Url, :string
        field :ShowOnCashBasisReports, :boolean
        field :Narration, :string
        field :HasAttachments, :boolean
        embeds_many :JournalLines, XeroXero.CoreApi.Models.ManualJournals.ManualJournal.JournalLine
        field :UpdatedDateUTC, :string
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string        
    end

    def changeset(struct, data) do
        struct
        |> cast(data, @fields)
        |> cast_embed(:JournalLines)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
