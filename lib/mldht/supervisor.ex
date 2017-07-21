defmodule MlDHT.Supervisor do

  @name __MODULE__

  use Supervisor

  def start_link(num_nodes) do
    Supervisor.start_link(__MODULE__, num_nodes, name: @name)
  end

  def init(num_nodes) do
    {node_ids, node_child_specs} = new(num_nodes) |> Enum.unzip

    children = [ worker(MlDHT.NodeList, [node_ids]) | node_child_specs ]

    opts = [strategy: :one_for_one, name: MlDHT.Supervisor]

    supervise(children, opts)
  end

  @doc """
  Spawns a new node on the DHT.
  """
  def new(num \\ 1)
  def new(num), do: DHTServer.Utils.gen_node_id() |> new(num)

  def new(node_id, num) when num > 1, do: [ starter(node_id, num) | new(num - 1) ]
  def new(node_id, num), do: [ starter(node_id, num) ]

  def starter(node_id, num) do
    socket_num = Application.get_env(:mldht, :port) + num

    { node_id, supervisor(MlDHT.Node, [node_id, socket_num], id: node_id) }
  end

end
