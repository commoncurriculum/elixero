defmodule XeroXero.CoreApi.Models.Allocations do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "allocations" do
        embeds_many :Allocations, XeroXero.CoreApi.Models.Allocations.Allocation
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:Allocations)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:Allocations => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:Allocations)
        |> apply_changes
    end
end
