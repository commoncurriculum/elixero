defmodule XeroXero.CoreApi.Models.Accounts do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "accounts" do
        embeds_many :Accounts, XeroXero.CoreApi.Models.Accounts.Account
    end

    def from_map(data) do
        %__MODULE__{}
        |> cast(data, [])
        |> cast_embed(:Accounts)
        |> apply_changes
    end

    def from_validation_exception(data) do
        remapped_data = %{:Accounts => data."Elements"}

        %__MODULE__{}
        |> cast(remapped_data, [])
        |> cast_embed(:Accounts)
        |> apply_changes
    end
end
