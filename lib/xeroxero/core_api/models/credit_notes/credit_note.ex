defmodule XeroXero.CoreApi.Models.CreditNotes.CreditNote do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :CreditNoteID,
        :CreditNoteNumber,
        :Type,
        :Reference,
        :SentToContact,
        :AppliedAmount,
        :RemainingCredit,
        :CurrencyRate,
        :Date,
        :DueDate,
        :BrandingThemeID,
        :Status,
        :LineAmountTypes,
        :SubTotal,
        :TotalTax,
        :Total,
        :CurrencyCode,
        :HasAttachments,
        :FullyPaidOnDate,
        :UpdatedDateUTC,
        :StatusAttributeString
    ]

    schema "creditnotes" do
        field :CreditNoteID, Ecto.UUID
        field :CreditNoteNumber, :string
        field :Type, :string
        field :Reference, :string
        field :SentToContact, :boolean
        field :AppliedAmount, :decimal
        field :RemainingCredit, :decimal
        field :CurrencyRate, :decimal
        embeds_one :Contact, XeroXero.CoreApi.Models.Contacts.Contact
        field :Date, :string
        field :DueDate, :string
        field :BrandingThemeID, Ecto.UUID
        field :Status, :string
        field :LineAmountTypes, :string
        field :SubTotal, :decimal
        field :TotalTax, :decimal
        field :Total, :decimal
        field :CurrencyCode, :string
        field :HasAttachments, :boolean
        field :FullyPaidOnDate, :string
        embeds_many :LineItems, XeroXero.CoreApi.Models.Common.LineItem
        embeds_many :Allocations, XeroXero.CoreApi.Models.Allocations.Allocation
        embeds_many :Payments, XeroXero.CoreApi.Models.Payments.Payment
        field :UpdatedDateUTC, :string
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string
    end

    def changeset(struct, data) do
        struct
        |> cast(data, @fields)
        |> cast_embed(:Contact)
        |> cast_embed(:LineItems)
        |> cast_embed(:Allocations)
        |> cast_embed(:Payments)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
