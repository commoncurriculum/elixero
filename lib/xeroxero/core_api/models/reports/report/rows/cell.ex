defmodule XeroXero.CoreApi.Models.Reports.Report.Rows.Cell do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :id]}

  schema "cells" do
    field :Value, :string
    embeds_many :Attributes, XeroXero.CoreApi.Models.Reports.Report.Rows.Cell.Attribute
  end

  def changeset(struct, data) do
    struct
    |> cast(data, [:Value])
    |> cast_embed(:Attributes)
  end
end
