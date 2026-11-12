defmodule XeroXero.CoreApi.Models.Payments.Payment do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    @fields [
        :PaymentID,
        :PaymentType,
        :Status,
        :Date,
        :CurrencyRate,
        :BankAmount,
        :Amount,
        :Reference,
        :IsReconciled,
        :UpdatedDateUTC,
        :StatusAttributeString
    ]

    schema "payments" do
        field :PaymentID, Ecto.UUID
        field :PaymentType, :string
        field :Status, :string
        field :Date, :string
        field :CurrencyRate, :decimal
        field :BankAmount, :decimal
        field :Amount, :decimal
        field :Reference, :string
        field :IsReconciled, :boolean
        embeds_one :Invoice, XeroXero.CoreApi.Models.Invoices.Invoice
        embeds_one :CreditNote, XeroXero.CoreApi.Models.CreditNotes.CreditNote
        embeds_one :Prepayment, XeroXero.CoreApi.Models.Prepayments.Prepayment
        embeds_one :Overpayment, XeroXero.CoreApi.Models.Overpayments.Overpayment
        embeds_one :Account, XeroXero.CoreApi.Models.Accounts.Account
        field :UpdatedDateUTC, :string
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string        
    end

    def changeset(struct, data) do
        struct
        |> cast(data, @fields)
        |> cast_embed(:Invoice)
        |> cast_embed(:CreditNote)
        |> cast_embed(:Prepayment)
        |> cast_embed(:Overpayment)
        |> cast_embed(:Account)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
