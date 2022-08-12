defmodule Gameplatform.Games.Schema.Banner do
  use Ecto.Schema

  schema "banners" do
    field :name, :string
    field :active, :boolean
    field :carousel_url, :string
    field :display_url, :string

    timestamps(type: :utc_datetime_usec)
  end
end
