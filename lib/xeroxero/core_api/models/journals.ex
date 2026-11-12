defmodule XeroXero.CoreApi.Models.Journals do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "journals" do
        embeds_many :Journals, XeroXero.CoreApi.Models.Journals.Journal
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:Journals)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:Journals => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:Journals)
        |> apply_changes
    end
end
