defmodule Gameplatform.Cache.Redis.RedixSupervisor do
  alias Gameplatform.Cache.ApiToConfig

  def child_spec(_args) do
    # Specs for the Redix connections.
    pool_size = ApiToConfig.get_pool_size()

    # sync_connect: true shuts tdown the app if redis server connection not possible
    children =
      for index <- 0..(pool_size - 1) do
        Supervisor.child_spec(
          {
            Redix,
            sync_connect: true, name: :"redix_#{index}"
          },
          id: {Redix, index}
        )
      end

    args = [children, [strategy: :one_for_one, name: __MODULE__]]

    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, args}
    }
  end
end
