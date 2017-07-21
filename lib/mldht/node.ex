defmodule MlDHT.Node do

  @moduledoc ~S"""
  MlDHT is an Elixir package that provides a Kademlia Distributed Hash Table
  (DHT) implementation according to [BitTorrent Enhancement Proposals (BEP)
  05](http://www.bittorrent.org/beps/bep_0005.html). This specific
  implementation is called "mainline" variant.


  """
  
  @typedoc """
  A binary which contains the infohash of a torrent. An infohash is a SHA1
  encoded hex sum which identifies a torrent.
  """
  @type infohash :: binary

  @typedoc """
  A non negative integer (0--65565) which represents a TCP port number.
  """
  @type tcp_port :: non_neg_integer

  @name __MODULE__

  alias MlDHT.Namespace

  use Supervisor

  defp routing_table_for(node_id, ip_version) do
    if Application.get_env(:mldht, ip_version) do
      worker(RoutingTable.Worker, [node_id, ip_version], [id: ip_version])
    end
  end

  @doc false
  def start_link(node_id, socket_num) do
    Supervisor.start_link(
      @name, [node_id, socket_num], name: Namespace.name(@name, node_id)
    )
  end

  def init([node_id, socket_num]) do
    ## Define workers and child supervisors to be supervised

    ## According to BEP 32 there are two distinct DHTs: the IPv4 DHT, and the
    ## IPv6 DHT. This means we need two seperate routing tables for each IP
    ## version.
    children = [] ++ [routing_table_for(node_id, :ipv4)] ++ [routing_table_for(node_id, :ipv6)]

    children = children ++ [
      worker(DHTServer.Worker,  [node_id, socket_num]),
      worker(DHTServer.Storage, [node_id])
    ]

    children = Enum.filter(children, fn (v) -> v != nil end)

    opts = [strategy: :one_for_one]

    supervise(children, opts)
  end

end
