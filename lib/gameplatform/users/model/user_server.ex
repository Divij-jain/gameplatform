defmodule Gameplatform.Users.Model.UserServer do
  @moduledoc """
  Defines the structure of user server process
  """

  alias __MODULE__
  alias Gameplatform.Games.Schema.{Banner, Game}
  alias Gameplatform.Accounts.Schema.UserProfile

  defstruct [:user_id, :user_channel, :games, :banners, :profile, :active_queue, :active_game]

  @type t :: %__MODULE__{
          user_id: integer() | nil,
          user_channel: String.t() | nil,
          games: list(Game.t()) | nil,
          banners: list(Banner.t()) | nil,
          profile: UserProfile.t() | nil,
          active_queue: String.t() | nil,
          active_game: String.t() | nil
        }

  @spec new(map()) :: __MODULE__.t()
  def new(%{user_id: user_id, user_channel: user_channel} = _args) do
    %__MODULE__{
      user_id: user_id,
      user_channel: user_channel
    }
  end

  @spec update_state(state :: __MODULE__.t(), args :: Keyword.t()) :: new_state :: __MODULE__.t()
  def update_state(%UserServer{} = state, [_ | _] = args) do
    List.foldl(args, state, fn {key, value}, acc ->
      if Map.has_key?(state, key) do
        Map.put(acc, key, value)
      else
        state
      end
    end)
  end
end
