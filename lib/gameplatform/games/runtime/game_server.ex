defmodule Gameplatform.Runtime.GameServer do
  use GenServer

  @moduledoc """
   Later we will convert this into Macro and override each gamelogic for every game using this macro just like Agent
  """

  # alias Gameplatform.Runtime.FlappyBirds
  alias Gameplatform.UserSupervisor

  def start_link(args) do
    table_id = create_table_id()
    GenServer.start_link(__MODULE__, args, name: via(table_id))
  end

  def init(args) do
    # module_name = get_game(args) |> get_module_name_for_state()
    players = args.players

    state = %{
      game_id: args.game_id,
      app_id: args.app_id,
      sku_code: args.sku_code,
      num_required_players: args.req_num_players,
      amount: args.amount,
      players: []
    }

    new_state = add_players_to_game(players, state)

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

  defp add_players_to_game(players, state) do
    args = Map.take(state, [:app_id, :game_id, :amount, :sku_code])

    new_players =
      Enum.reduce(players, state.players, fn player, acc ->
        case UserSupervisor.call_message(player, {:adding_user_to_game, args}) do
          {:ok, _} ->
            acc ++ [player]

          {:error, _} ->
            acc
        end
      end)

    %{state | players: new_players}
  end

  # defp get_game(opts) do
  #   app_id = Map.get(opts, :app_id)
  # end

  # defp get_module_name_for_state("flappy_birds"), do: FlappyBird

  defp via(key) do
    {:via, Registry, {Gameplatform.GameRegistry, key}}
  end
end
