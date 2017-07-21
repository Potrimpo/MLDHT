defmodule RoutingTable.Worker.Test do
  use ExUnit.Case

  alias RoutingTable.Worker, as: RoutingTable

  @name :test
  @tag updated: true

  setup_all do
    node_id = MlDHT.NodeList.get()
    [node_id: node_id]
  end

  setup(context) do
    {:ok, _pid} = RoutingTable.start_link(context[:node_id], :test)
    RoutingTable.node_id(:test, context[:node_id], "AA")
  end

  test "If the function node_id can set and get the node_id", context do
    RoutingTable.node_id(:test, context[:node_id], "BB")
    assert RoutingTable.node_id(:test, context[:node_id]) == "BB"
  end

  test "If the size of the table is 0 if we add and delete a node", context do
    RoutingTable.add(:test, context[:node_id], "BB", {{127, 0, 0, 1}, 6881}, 23)
    assert RoutingTable.size(:test, context[:node_id]) == 1

    RoutingTable.del(:test, context[:node_id], "BB")
    assert RoutingTable.size(:test, context[:node_id]) == 0
  end

  test "get_node", context do
    assert :ok == RoutingTable.add(:test, context[:node_id], "BB", {{127, 0, 0, 1}, 6881}, 23)

    assert RoutingTable.get(:test, context[:node_id], "BB") |> Kernel.is_pid == true
    assert RoutingTable.get(:test, context[:node_id], "CC") == nil

    RoutingTable.del(:test, context[:node_id], "BB")
  end

  test "foo", context do
    nodes = [
      "32F54E697351FF4AEC29CDBAABF2FBE3467CC267",
      "93990A2BE65C366458EF03ACB48680AE83D2AD94",
      "9399182C807EC599D5E980B2EAC9CC53BF67D69D",
      "93991B09293CE71A85B44D0578D576B9D09CC095",
      "91478CDBD190E87D21C273F493957590A78D2B50",
      "93991F40B451BE18D727BFCAE0EA1722FD65732A",
      "9077C97800E42B0757E4F39FF8DD9E3E8AB67675",
      "96CB5CEA7C9FB775C1FB74DE0121D7A11309ECC7",
      "527429EE61360B9D6A69BCCE493FB12250BE7ECE",
      "A14E7753748539120787BCE2B9815CC80AF3174C",
      "003E8F4139A0174FB0F1983B87D76DFACD29B783",
      "93990647DEB3124DC843BB8BA61F035A7D093806",
    ]

    ## set a real node id
    RoutingTable.node_id(:test, context[:node_id], Base.decode16!("FC8A15A2FAF2734DBB1DC5F7AFDC5C9BEAEB1F59"))

    ## add all nodes
    Enum.map(nodes, fn(x) ->
      RoutingTable.add(:test, context[:node_id], Base.decode16!(x), {{127, 0, 0, 1}, 6881}, 23)
    end)

    RoutingTable.print(:test, context[:node_id])
    RoutingTable.closest_nodes(:test, context[:node_id], Base.decode16!("DAC8FAC14C12BB46E25F15D810BBD14267AD4ECA"))

    Enum.map(nodes, fn(x) -> RoutingTable.del(:test, context[:node_id], Base.decode16!(x)) end)
    # RoutingTable.print
    RoutingTable.node_id(:test, context[:node_id], "AA")
  end

  test "Double entries", context do
    RoutingTable.add(:test, context[:node_id], "BB", {{127, 0, 0, 1}, 6881}, 23)
    RoutingTable.add(:test, context[:node_id], "BB", {{127, 0, 0, 1}, 6881}, 23)

    assert RoutingTable.size(:test, context[:node_id]) == 1
    RoutingTable.del(:test, context[:node_id], "BB")
  end

end
