defmodule XeroXero.CoreApi.Models.Allocations.Allocation do
    use Ecto.Schema
    import Ecto.Changeset
    
    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "allocations" do
        embeds_one :CreditNote, XeroXero.CoreApi.Models.CreditNotes.CreditNote        
        embeds_one :Prepayment, XeroXero.CoreApi.Models.Prepayments.Prepayment
        embeds_one :Overpayment, XeroXero.CoreApi.Models.Overpayments.Overpayment
        field :Amount, :decimal
        field :Date, :string
        embeds_one :Invoice, XeroXero.CoreApi.Models.Invoices.Invoice
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:Amount, :Date, :StatusAttributeString])
        |> cast_embed(:CreditNote)
        |> cast_embed(:Prepayment)
        |> cast_embed(:Overpayment)
        |> cast_embed(:Invoice)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
