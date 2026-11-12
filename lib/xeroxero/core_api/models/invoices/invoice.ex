defmodule XeroXero.CoreApi.Models.Invoices.Invoice do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :InvoiceID,
        :InvoiceNumber,
        :Type,
        :Status,
        :LineAmountTypes,
        :Date,
        :DueDate,
        :ExpectedPaymentDate,
        :PlannedPaymentDate,
        :SubTotal,
        :TotalTax,
        :TotalDiscount,
        :Total,    
        :CurrencyCode,
        :CurrencyRate,
        :FullyPaidOnDate,
        :AmountDue,
        :AmountPaid,
        :AmountCredited,
        :HasAttachments,
        :BrandingThemeID,
        :Url,
        :Reference,
        :SentToContact,
        :UpdatedDateUTC,
        :StatusAttributeString
    ]

    schema "invoices" do
        field :InvoiceID, Ecto.UUID
        field :InvoiceNumber, :string
        embeds_one :Contact, XeroXero.CoreApi.Models.Contacts.Contact
        field :Type, :string
        field :Status, :string
        field :LineAmountTypes, :string
        field :Date, :string
        field :DueDate, :string
        field :ExpectedPaymentDate, :string
        field :PlannedPaymentDate, :string
        field :SubTotal, :decimal
        field :TotalTax, :decimal
        field :TotalDiscount, :decimal
        field :Total, :decimal     
        field :CurrencyCode, :string  
        field :CurrencyRate, :decimal
        field :FullyPaidOnDate, :string
        field :AmountDue, :decimal
        field :AmountPaid, :decimal
        field :AmountCredited, :decimal
        field :HasAttachments, :boolean
        field :BrandingThemeID, Ecto.UUID
        field :Url, :string
        field :Reference, :string
        embeds_many :LineItems, XeroXero.CoreApi.Models.Common.LineItem
        field :SentToContact, :boolean
        embeds_many :CreditNotes, XeroXero.CoreApi.Models.CreditNotes.CreditNote
        embeds_many :Prepayments, XeroXero.CoreApi.Models.Prepayments.Prepayment
        embeds_many :Overpayments, XeroXero.CoreApi.Models.Overpayments.Overpayment
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
        |> cast_embed(:CreditNotes)
        |> cast_embed(:Prepayments)
        |> cast_embed(:Overpayments)
        |> cast_embed(:Payments)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
