defmodule Gameplatform.Runtime.GameServer do
  use GenServer

  # alias Gameplatform.Runtime.FlappyBirds

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
      sku_code: args.sku_code(num_required_players: args.req_num_players, amount: args.amount)
    }

    add_users_to_game(players)
    {:ok, state}
  end

  def handle_cast(message, state) do
  end

  def handle_call(message, state) do
  end

  def handle_info(:timeout, state) do
  end

  defp create_table_id() do
    node = Enum.at(String.split(Atom.to_string(node()), "@"), 1)
    id = Ecto.UUID.generate()
    "#{id}_#{node}"
  end

  defp add_users_to_game(players) do
    for player <- players do
    end
  end

  defp get_game(opts) do
    app_id = Map.get(opts, :app_id)
  end

  defp get_module_name_for_state("flappy_birds"), do: FlappyBird

  defp via(key) do
    {:via, Registry, {Gameplatform.GameRegistry, key}}
  end
end
