defmodule XeroXero.CoreApi.Models.TaxRates do
    use Ecto.Schema
    import Ecto.Changeset
    
    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "taxrates" do
        embeds_many :TaxRates, XeroXero.CoreApi.Models.TaxRates.TaxRate
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:TaxRates)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:TaxRates => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:TaxRates)
        |> apply_changes
    end
end
