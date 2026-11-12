defmodule XeroXero.CoreApi.Models.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :id]}

  @fields [
    :id_token,
    :access_token,
    :expires_in,
    :token_type,
    :refresh_token,
    :scope
]

schema "tokens" do
    field :id_token, :string
    field :access_token, :string
    field :expires_in, :integer
    field :token_type, :string
    field :refresh_token, :string
    field :scope, :string
end

def from_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes
end

def from_validation_exception(data) do
    remapped_data = %{:Token => data."Elements"}

    %__MODULE__{}
    |> cast(remapped_data, [])
    |> apply_changes
end

  def changeset(struct, data) do
      struct
      |> cast(data, @fields)
  end
end
