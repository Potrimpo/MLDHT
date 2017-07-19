defmodule DHTServer.Storage.Test do
  use ExUnit.Case
  require Logger

  alias DHTServer.Storage

  @tag updated: true

  setup_all do
    node_id = DHTServer.Utils.gen_node_id()
    [ok: _pid] = MlDHT.Supervisor.new(node_id, 1)

    [node_id: node_id]
  end 

  test "has_nodes_for_infohash?", context do
    Storage.put(context[:node_id], "aaaa", {127, 0, 0, 1}, 6881)

    assert Storage.has_nodes_for_infohash?(context[:node_id], "bbbb") == false
    assert Storage.has_nodes_for_infohash?(context[:node_id], "aaaa") == true
  end

  test "get_nodes", context do
    Storage.put(context[:node_id], "aaaa", {127, 0, 0, 1}, 6881)
    Storage.put(context[:node_id], "aaaa", {127, 0, 0, 1}, 6881)
    Storage.put(context[:node_id], "aaaa", {127, 0, 0, 2}, 6882)

    Storage.print

    assert Storage.get_nodes(context[:node_id], "aaaa") == [{{127,0,0,1}, 6881}, {{127, 0, 0, 2}, 6882}]
  end

end
