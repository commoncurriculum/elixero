defmodule XeroXero.CoreApi.Models.Common.PaymentTerms do
    use Ecto.Schema
    import Ecto.Changeset
    
    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "paymentterms" do
        embeds_one :Bills, XeroXero.CoreApi.Models.Common.PaymentTerms.Terms
        embeds_one :Sales, XeroXero.CoreApi.Models.Common.PaymentTerms.Terms
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string
    end

    def changeset(struct, data) do
        struct 
        |> cast(data, [:StatusAttributeString])
        |> cast_embed(:Bills)
        |> cast_embed(:Sales)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end    
end
