defmodule XeroXero.CoreApi.Models.Attachments.Attachment do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, except: [:__meta__, :id]}

    schema "attachments" do
        field :AttachmentID, Ecto.UUID
        field :FileName, :string
        field :Url, :string
        field :MimeType, :string
        field :ContentLength, :integer
        field :IncludeOnline, :boolean
    end

    def changeset(struct, data) do
        struct
        |> cast(data, [:AttachmentID, :FileName, :Url, :MimeType, :ContentLength, :IncludeOnline])
    end
end
