defmodule Gameplatform.Games.Schema.Banner do
  use Gameplatform.Schema

  @moduledoc false

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
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
