defmodule XeroXero.CoreApi.Models.Contacts.Contact.BatchPayments do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "batchpayments" do
        field :BankAccountNumber, :string
        field :BankAccountName, :string
        field :Details, :string
        field :Code, :string
        field :Reference, :string
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string
    end

    def changeset(struct, data) do
        struct 
        |> cast(data, [:BankAccountNumber, :BankAccountName, :Details, :Code, :Reference, :StatusAttributeString])
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
