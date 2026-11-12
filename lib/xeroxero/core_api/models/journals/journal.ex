defmodule XeroXero.CoreApi.Models.Journals.Journal do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :JournalID,
        :JournalDate,
        :JournalNumber,
        :CreatedDateUtc,
        :Reference,
        :SourceId,
        :SourceType,
        :StatusAttributeString 
    ]

    schema "journals" do
        field :JournalID, Ecto.UUID
        field :JournalDate, :string
        field :JournalNumber, :integer
        field :CreatedDateUtc, :string
        field :Reference, :string
        embeds_many :JournalLines, XeroXero.CoreApi.Models.Journals.Journal.JournalLine
        field :SourceId, :string
        field :SourceType, :string
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
