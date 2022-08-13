defmodule Gameplatform.UserWorker do
  @moduledoc """
  This module handles all the operations related to the app user.
  """

  use GenServer

  alias Gameplatform.Account
  alias Gameplatform.Cache
  alias Gameplatform.Game
  alias GameplatformWeb.Utils

  # main_app:user:

  @initial_state %{
    user_channel: nil,
    user_id: nil,
    state: nil,
    games: nil,
    banners: nil,
    profile: nil
  }

  @timeout 15_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init([user_id, user_channel]),
    do:
      {:ok, %{@initial_state | user_id: user_id, user_channel: user_channel},
       {:continue, user_channel}}

  @impl true
  def handle_continue(user_channel, state) do
    case Cache.set_key_in_cache(user_channel, :erlang.pid_to_list(self())) do
      {:ok, "OK"} ->
        initialise_login(state)

      _ ->
        {:stop, :redis_error}
    end
  end

  @impl true
  def handle_info(:timeout, state), do: {:noreply, state, @timeout}

  @impl true
  def handle_cast(:initialise_login, state), do: initialise_login(state)

  @impl true
  def terminate(reason, state) do
    Cache.delete_value_from_cache(state.user_channel)
    {:stop, reason}
  end

  defp initialise_login(state) do
    banners = Game.get_active_banners()
    banners = Enum.map(banners, &Utils.schema_struct_to_map/1)

    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:banners", %{banners: banners})

    games = Game.get_active_games()
    games = Enum.map(games, &Utils.schema_struct_to_map/1)
    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:games", %{games: games})

    {:ok, user} = Account.get_complete_user(state.user_id)
    profile = get_profile(user)

    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:profile", %{profile: profile})

    new_state = %{state | banners: banners, games: games, profile: profile}

    {:noreply, new_state, @timeout}
  end

  def get_profile(user) do
    %{
      user_profile: extract_user_profile(user.user_profiles),
      user_wallets: parse_user_wallets(user.user_profiles.user_wallets, [])
    }
  end

  def get_user_wallet_txs(profile) do
    wallet = get_wallet(profile.user_wallets, "user_wallet")

    case wallet do
      nil ->
        []

      wallet ->
        wallet.user_wallet_txs
    end
  end

  defp parse_user_wallets([], acc), do: acc

  defp parse_user_wallets([user_wallet | tail_user_wallets], acc) do
    acc2 = [extract_user_wallet(user_wallet)] ++ acc
    parse_user_wallets(tail_user_wallets, acc2)
  end

  defp extract_user_wallet(user_wallet) do
    Map.take(user_wallet, [
      :id,
      :user_wallet,
      :wallet_type,
      :user_wallet_txs,
      :updated_at,
      :inserted_at
    ])
  end

  defp extract_user_profile(user_profiles) do
    Map.take(user_profiles, [
      :email,
      :first_name,
      :second_name,
      :kyc_status,
      :phone_number,
      :gender,
      :image
    ])
  end

  defp get_wallet(wallets, wallet_type) do
    Enum.find(wallets, nil, fn wallet ->
      wallet.wallet_type == wallet_type
    end)
  end
end
