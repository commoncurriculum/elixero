defmodule XeroXero.CoreApi.Models.ExpenseClaims do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "expenseclaims" do
        embeds_many :ExpenseClaims, XeroXero.CoreApi.Models.ExpenseClaims.ExpenseClaim
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:ExpenseClaims)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:ExpenseClaims => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:ExpenseClaims)
        |> apply_changes
    end
end
