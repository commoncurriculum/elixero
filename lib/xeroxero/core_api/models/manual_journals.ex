defmodule XeroXero.CoreApi.Models.ManualJournals do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "manualjournals" do
        embeds_many :ManualJournals, XeroXero.CoreApi.Models.ManualJournals.ManualJournal
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:ManualJournals)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:ManualJournals => data."Elements"}
        
        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:ManualJournals)
        |> apply_changes
    end
end
