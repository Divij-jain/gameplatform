defmodule Gameplatform.Users.UserServer do
  @moduledoc """
  This module handles all the operations related to the app user.
  """

  use GenServer

  alias Gameplatform.{Account, Cache, Game}
  alias Gameplatform.GameQueue.QueueSupervisor
  alias Gameplatform.Accounts.Schema.{User, UserProfile, UserWallet, UserWalletTx}
  alias Gameplatform.Games.Schema.Game, as: GameModel
  alias Gameplatform.Users.UserSupervisor
  alias Gameplatform.Users.Model.UserServer, as: UserModel
  alias GameplatformWeb.Utils
  # main_app:user:

  @promotional_percentage 10
  @timeout 15_000

  def start_link(opts) do
    user_id = Map.get(opts, :user_id)
    GenServer.start_link(__MODULE__, opts, name: via(user_id))
  end

  @impl true
  def init(%{user_id: user_id, user_channel: user_channel}) do
    %UserModel{} = state = UserModel.new(%{user_id: user_id, user_channel: user_channel})
    {:ok, state, {:continue, :intialise}}
  end

  @impl true
  def handle_continue(:intialise, %UserModel{} = state) do
    process_identifier = UserSupervisor.get_proc_identifier(state.user_id)

    case Cache.set_key_in_cache(process_identifier, :erlang.pid_to_list(self())) do
      {:ok, "OK"} ->
        new_state = initialise_login(state)
        send_data(new_state)
        {:noreply, new_state, @timeout}

      _ ->
        {:stop, :redis_error}
    end
  end

  @impl true
  def handle_info(:timeout, state), do: {:noreply, state, @timeout}

  @impl true
  def handle_cast(:initialise_login, state) do
    send_data(state)
    {:noreply, state, @timeout}
  end

  @impl true
  def handle_call(
        {:game_join, %{"game_id" => game_id, "sku_id" => sku_id} = payload},
        _from,
        state
      ) do
    IO.inspect([game_id, sku_id], label: "checking type for incoming packets")

    with {:ok, amount} <- get_sku_amount(game_id, sku_id, state.games),
         :ok <- check_user_balance(amount, state.profile),
         nil <- check_active_queue_table(state),
         {:ok, _} <-
           QueueSupervisor.add_user_to_queue(
             Map.put(payload, "amount", amount),
             state.user_id
           ) do
      new_state = UserModel.update_state(state, active_queue: true)
      {:reply, {:ok, {%{}, "Joined Successfully"}}, new_state, @timeout}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state, @timeout}
    end
  end

  def handle_call({:adding_user_to_game, args}, _from, state) do
    amount = Map.get(args, :amount)

    # later to add active table as well

    state
    |> remove_active_queue_table()
    |> update_balance_for_user(amount, "user_wallet")
    |> case do
      {:ok, new_state} ->
        player = %{user_channel: new_state.user_channel}
        {:reply, {:ok, player}, new_state, @timeout}

      error ->
        reply = error
        {:reply, reply, state, @timeout}
    end
  end

  @impl true
  def terminate(reason, state) do
    Cache.delete_value_from_cache(state.user_channel)
    {:stop, reason}
  end

  defp via(user_id) do
    proc_name = UserSupervisor.get_proc_identifier(user_id)
    {:via, Registry, {Gameplatform.UserRegistry, proc_name}}
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

  defp get_game(games, game_id),
    do: Enum.find(games, fn %GameModel{} = game -> game.id == game_id end)

  defp get_sku(nil, _sku_id), do: nil

  defp get_sku(%GameModel{} = game, sku_id),
    do: Enum.find(game.game_skus, fn sku -> sku.id == sku_id end)

  defp check_active_queue_table(%{active_queue: nil, active_game: nil}), do: nil
  defp check_active_queue_table(_), do: {:error, "Already joined on a game!"}

  def remove_active_queue_table(state) do
    UserModel.update_state(state, active_queue: nil)
  end

  defp initialise_login(state) do
    banners = get_banners()
    games = get_games()
    profile = get_user_profile(state.user_id)

    UserModel.update_state(state, banners: banners, games: games, profile: profile)
  end

  def send_data(state) do
    send_banners(state)
    send_games(state)
    send_profile(state)
  end

  defp get_banners, do: Game.get_active_banners()

  defp get_games, do: Game.get_active_games()

  defp get_user_profile(user_id) do
    {:ok, %User{} = user} = Account.get_complete_user(user_id)
    user.user_profile
  end

  defp send_banners(%{banners: banners} = state) do
    banners = Enum.map(banners, &Utils.to_json/1)
    send_data_to_client(state.user_channel, "main_app:banners", %{banners: banners})
  end

  defp send_games(%{games: games} = state) do
    games = Enum.map(games, &Utils.to_json/1)
    send_data_to_client(state.user_channel, "main_app:games", %{games: games})
  end

  defp send_profile(%{profile: profile} = state) do
    profile = parse_profile(profile)
    send_data_to_client(state.user_channel, "main_app:profile", %{profile: profile})
  end

  defp send_data_to_client(user_channel, topic, data) do
    GameplatformWeb.Endpoint.broadcast(user_channel, topic, data)
  end

  defp check_user_balance(amount, profile) do
    user_wallet_balance = get_wallet_balance(profile, "user_wallet")
    promotional_wallet_balance = get_wallet_balance(profile, "promotional_wallet")

    promotional_amount =
      Decimal.mult(
        min(amount, promotional_wallet_balance),
        Decimal.from_float(@promotional_percentage / 100)
      )

    user_wallet_amount = Decimal.sub(amount, promotional_amount)

    case user_wallet_balance >= user_wallet_amount do
      true ->
        :ok

      _ ->
        {:error, "Insufficient Funds!"}
    end
  end

  defp get_wallet_balance(%UserProfile{} = profile, wallet_type) do
    case get_wallet(profile.user_wallets, wallet_type) do
      nil ->
        Decimal.new(0)

      %UserWallet{} = wallet ->
        Enum.reduce(wallet.user_wallet_txs, Decimal.new(0), fn %UserWalletTx{} = txn, acc ->
          Decimal.add(acc, txn.amount)
        end)
    end
  end

  defp get_wallet(wallets, wallet_type) do
    Enum.find(wallets, nil, fn %UserWallet{} = wallet ->
      wallet.wallet_type == wallet_type
    end)
  end

  defp parse_profile(user_profile) do
    %{
      user_profile: Utils.to_json(user_profile),
      user_wallets: Enum.map(user_profile.user_wallets, &Utils.to_json/1)
    }
  end

  defp update_balance_for_user(state, amount, wallet_type) do
    case get_wallet(state.profile.user_wallets, wallet_type) do
      nil ->
        {:error, :no_wallet_found}

      %UserWallet{} = wallet ->
        attrs = %{
          amount: amount,
          user_wallet_id: wallet.id,
          meta_tx_id: Ecto.UUID.generate(),
          tx_type: :credit
        }

        update_tx_in_wallet(amount, attrs, wallet, state)
    end
  end

  def update_tx_in_wallet(amount, attrs, wallet, state) do
    case amount > 0 do
      true ->
        Account.add_money_to_wallet(attrs)

      false ->
        case check_user_balance(amount, state.profile) do
          :ok ->
            Account.deduct_money_from_wallet(attrs)

          _ ->
            {:error, :not_enough_balance}
        end
    end
    |> case do
      {:ok, tx} ->
        {:ok, add_tx_to_profile(state, wallet, tx)}

      error ->
        error
    end
  end

  def add_tx_to_profile(state, wallet, tx) do
    new_wallet = add_tx_to_wallet(wallet, tx)

    new_profile = %{
      state.profile
      | user_wallets: update_wallets(state.profile.user_wallets, new_wallet)
    }

    UserModel.update_state(state, profile: new_profile)
  end

  def update_wallets(user_wallets, new_wallet) do
    Enum.reduce(user_wallets, [], fn wallet, acc ->
      if wallet.wallet_type == new_wallet.wallet_type do
        acc ++ [new_wallet]
      else
        acc ++ [wallet]
      end
    end)
  end

  defp add_tx_to_wallet(%UserWallet{} = wallet, tx) do
    new_wallet_txs = wallet.user_wallet_txs ++ [tx]
    %{wallet | user_wallet_txs: new_wallet_txs}
  end
end
