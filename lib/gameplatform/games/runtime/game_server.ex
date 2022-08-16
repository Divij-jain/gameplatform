defmodule Gameplatform.Runtime.GameServer do
  use GenServer

  @moduledoc """
   Later we will convert this into Macro and override each gamelogic for every game using this macro just like Agent
  """

  # alias Gameplatform.Runtime.FlappyBirds
  alias Gameplatform.UserSupervisor
  alias Gameplatform.Games.Runtime.Model.Game

  def start_link([args]) do
    table_id = create_table_id()
    args = Map.put(args, :table_id, table_id)
    GenServer.start_link(__MODULE__, args, name: via(table_id))
  end

  def init(args) do
    # module_name = get_game(args) |> get_module_name_for_state()
    players = args.players
    state = Game.new(args)

    new_state = add_players_to_game(players, state)
    send_game_info_to_players(state)
    {:ok, new_state}
  end

  # def handle_cast(message, state) do
  # end

  # def handle_call(message, state) do
  # end

  # def handle_info(:timeout, state) do
  # end

  defp create_table_id() do
    node = Enum.at(String.split(Atom.to_string(node()), "@"), 1)
    id = Ecto.UUID.generate()
    "#{id}_#{node}"
  end

  defp add_players_to_game(players, %Game{} = state) do
    args = Map.take(state, [:app_id, :game_id, :amount, :sku_code, :table_id])

    new_players =
      Enum.reduce(players, state.players, fn user_id, acc ->
        case UserSupervisor.call_message(user_id, {:adding_user_to_game, args}) do
          {:ok, %{user_channel: user_channel}} ->
            player = Game.Player.new(%{user_id: user_id, user_channel: user_channel})
            acc ++ [player]

          {:error, _} ->
            acc
        end
      end)

    %{state | players: new_players}
  end

  defp send_game_info_to_players(%Game{} = state) do
    data = %{
      table_id: state.table_id,
      players: extract_players(state.players)
    }

    # Utils.to_json(data)
    json_data = Jason.encode(data)

    Enum.each(state.players, fn player ->
      GameplatformWeb.Endpoint.broadcast(player.user_channel, "main_app:game_info", json_data)
    end)
  end

  def extract_players(players) do
    players
  end

  # defp get_game(opts) do
  #   app_id = Map.get(opts, :app_id)
  # end

  # defp get_module_name_for_state("flappy_birds"), do: FlappyBird

  defp via(key) do
    {:via, Registry, {Gameplatform.GameRegistry, key}}
  end
end
