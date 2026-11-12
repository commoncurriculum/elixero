defmodule XeroXero.CoreApi.Models.RepeatingInvoices.RepeatingInvoice do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :RepeatingInvoiceID,
        :Type,
        :LineAmountTypes,
        :Reference,
        :BrandingThemeID,
        :CurrencyCode,
        :Status,
        :SubTotal,
        :TotalTax,
        :Total,   
        :HasAttachments,
        :StatusAttributeString
    ]

    schema "repeatinginvoices" do
        field :RepeatingInvoiceID, Ecto.UUID
        field :Type, :string
        embeds_one :Contact, XeroXero.CoreApi.Models.Contacts.Contact
        embeds_one :Schedule, XeroXero.CoreApi.Models.RepeatingInvoices.RepeatingInvoice.Schedule
        embeds_many :LineItems, XeroXero.CoreApi.Models.Common.LineItem
        field :LineAmountTypes, :string
        field :Reference, :string
        field :BrandingThemeID, Ecto.UUID
        field :CurrencyCode, :string
        field :Status, :string
        field :SubTotal, :decimal
        field :TotalTax, :decimal
        field :Total, :decimal    
        field :HasAttachments, :boolean
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string        
    end

    def changeset(struct, data) do
        struct
        |> cast(data, @fields)
        |> cast_embed(:Contact)
        |> cast_embed(:Schedule)
        |> cast_embed(:LineItems)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
