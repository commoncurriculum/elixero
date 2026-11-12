defmodule XeroXero.CoreApi.Models.Employees.Employee do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "employees" do
        field :EmployeeID, Ecto.UUID
        field :Status, :string
        field :FirstName, :string
        field :LastName, :string
        embeds_one :ExternalLink, XeroXero.CoreApi.Models.Common.ExternalLink
        embeds_many :ValidationErrors, XeroXero.CoreApi.Models.Common.Error
        embeds_many :Warnings, XeroXero.CoreApi.Models.Common.Warning
        field :StatusAttributeString, :string   
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:EmployeeID, :Status, :FirstName, :LastName, :StatusAttributeString])
        |> cast_embed(:ExternalLink)
        |> cast_embed(:ValidationErrors)
        |> cast_embed(:Warnings)
    end
end
