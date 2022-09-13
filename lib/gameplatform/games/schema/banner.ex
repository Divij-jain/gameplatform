defmodule Gameplatform.Games.Schema.Banner do
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: number(),
          name: String.t(),
          active: boolean(),
          carousel_url: String.t(),
          display_url: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "banners" do
    field :name, :string
    field :active, :boolean
    field :carousel_url, :string
    field :display_url, :string

    timestamps(type: :utc_datetime_usec)
  end
end
