defmodule Gameplatform.GameQueue.QueueSupervisorTest do
  use Gameplatform.DataCase

  alias Gameplatform.GameQueue.QueueSupervisor

  import Gameplatform.Factory

  describe "start_link/1" do
    test "registered supervisor process already started with application" do
      assert {:error, {:already_started, _}} = QueueSupervisor.start_link([])

      assert pid = Process.whereis(QueueSupervisor)
      assert is_pid(pid)
    end
  end
end
