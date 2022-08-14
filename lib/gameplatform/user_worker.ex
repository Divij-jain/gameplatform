defmodule Gameplatform.UserWorker do
  @moduledoc """
  This module handles all the operations related to the app user.
  """

  use GenServer

  alias Gameplatform.Account
  alias Gameplatform.Cache
  alias Gameplatform.Game
  alias Gameplatform.GameQueue.QueueSupervisor
  alias GameplatformWeb.Utils

  # main_app:user:

  @initial_state %{
    user_channel: nil,
    user_id: nil,
    state: nil,
    games: nil,
    banners: nil,
    profile: nil,
    active_queue: nil,
    active_game: nil
  }

  @promotional_percentage 10

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
  def handle_call(
        {:game_join,
         %{
           "game_id" => game_id,
           "sku_id" => sku_id
         } = payload, user_id},
        _from,
        state
      ) do
    IO.inspect(["@@@ --> ", payload])

    with {:ok, amount} <- get_sku_amount(game_id, sku_id, state.games),
         :ok <- check_user_balance(amount, state.profile),
         nil <- check_active_queue_table(state),
         {:ok, _} <-
           QueueSupervisor.add_user_to_queue(
             Map.put(payload, "amount", Decimal.to_string(amount)),
             user_id
           ) do
      new_state = %{state | active_queue: true}
      {:reply, {:ok, {%{}, "Joined Successfully"}}, new_state, @timeout}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state, @timeout}
    end
  end

  @impl true
  def terminate(reason, state) do
    Cache.delete_value_from_cache(state.user_channel)
    {:stop, reason}
  end

  defp get_sku_amount(game_id, sku_id, games) do
    games
    |> get_game(game_id)
    |> get_sku(sku_id)
    |> case do
      nil ->
        {:error, "Invalid Request!!"}

      sku ->
        {:ok, sku.amount}
    end
  end

  defp get_game(games, game_id), do: Enum.find(games, fn game -> game.id == game_id end)
  defp get_sku(nil, _sku_id), do: nil
  defp get_sku(game, sku_id), do: Enum.find(game.game_skus, fn sku -> sku.id == sku_id end)

  defp check_active_queue_table(%{active_queue: nil, active_game: nil}), do: nil
  defp check_active_queue_table(_), do: {:error, "Already joined on a game!"}

  defp initialise_login(state) do
    banners = send_banners(state)
    games = send_games(state)
    profile = send_profile(state)

    new_state = %{state | banners: banners, games: games, profile: profile}

    {:noreply, new_state, @timeout}
  end

  defp send_banners(%{banners: nil} = state) do
    banners = Game.get_active_banners()
    banners = Enum.map(banners, &Utils.to_json/1)

    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:banners", %{banners: banners})

    banners
  end

  defp send_banners(%{banners: banners} = state) do
    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:banners", %{banners: banners})

    banners
  end

  defp send_games(%{games: nil} = state) do
    games = Game.get_active_games()
    games = Enum.map(games, &Utils.to_json/1)
    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:games", %{games: games})
    games
  end

  defp send_games(%{games: games} = state) do
    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:games", %{games: games})
    games
  end

  defp send_profile(%{profile: nil} = state) do
    {:ok, user} = Account.get_complete_user(state.user_id)
    profile = get_profile(user)

    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:profile", %{profile: profile})

    profile
  end

  defp send_profile(%{profile: profile} = state) do
    GameplatformWeb.Endpoint.broadcast(state.user_channel, "main_app:profile", %{profile: profile})

    profile
  end

  defp check_user_balance(amount, profile) do
    amount = Decimal.to_float(amount)
    user_wallet_balance = get_wallet_balance(profile, "user_wallet")
    promotional_wallet_balance = get_wallet_balance(profile, "promotional_wallet")

    promotional_amount = min(amount, promotional_wallet_balance) * (@promotional_percentage / 100)
    user_wallet_amount = amount - promotional_amount

    case user_wallet_balance >= user_wallet_amount do
      true ->
        :ok

      _ ->
        {:error, "Insufficient Funds!"}
    end
  end

  defp get_wallet_balance(profile, wallet_type) do
    case get_wallet(profile.user_wallets, wallet_type) do
      nil ->
        0

      wallet ->
        Enum.reduce(wallet.user_wallet_txs, 0, fn txn, acc ->
          acc + Decimal.to_float(txn.amount)
        end)
    end
  end

  defp get_wallet(wallets, wallet_type) do
    Enum.find(wallets, nil, fn wallet ->
      wallet.wallet_type == wallet_type
    end)
  end

  defp get_profile(user) do
    %{
      user_profile: Utils.to_json(user.user_profiles),
      user_wallets: Enum.map(user.user_profiles.user_wallets, &Utils.to_json/1)
    }
  end

  # defp parse_user_wallets([], acc), do: acc

  # defp parse_user_wallets([user_wallet | tail_user_wallets], acc) do
  #   acc2 = [extract_user_wallet(user_wallet)] ++ acc
  #   parse_user_wallets(tail_user_wallets, acc2)
  # end

  # defp extract_user_wallet(user_wallet) do
  #   Map.take(user_wallet, [
  #     :id,
  #     :user_wallet,
  #     :wallet_type,
  #     :user_wallet_txs,
  #     :updated_at,
  #     :inserted_at
  #   ])
  # end

  # defp extract_user_profile(user_profiles) do
  #   Map.take(user_profiles, [
  #     :email,
  #     :first_name,
  #     :second_name,
  #     :kyc_status,
  #     :phone_number,
  #     :gender,
  #     :image
  #   ])
  # end
end
