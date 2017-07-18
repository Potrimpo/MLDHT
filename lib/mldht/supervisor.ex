defmodule MlDHT.Supervisor do

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

  use Supervisor

  @doc false
  def start_link do
    Supervisor.start_link(@name, [], name: @name)
  end

  def init([]) do
    children = [
      supervisor(MlDHT.Node, [])
    ]

    opts = [strategy: :simple_one_for_one, name: MlDHT.Supervisor]

    supervise(children, opts)
  end

  @doc """
  Spawns a new node on the DHT.
  Can take a pre-computed node_id (useful for testing purposes)
  """
  def new(num \\ 1)
  def new(num), do: DHTServer.Utils.gen_node_id() |> new(num)

  def new(node_id, num) when num > 1, do: [ starter(node_id, num) | new(num - 1) ]
  def new(node_id, num), do: [ starter(node_id, num) ]

  def starter(node_id, num) do
    cfg_port = Application.get_env(:mldht, :port) + num
    Supervisor.start_child(@name, [node_id, cfg_port])
  end

  @doc ~S"""
  This function needs an infohash as binary and a callback function as
  parameter. This function uses its own routing table as a starting point to
  start a get_peers search for the given infohash.

  ## Example
      iex> "3F19B149F53A50E14FC0B79926A391896EABAB6F" ## Ubuntu 15.04
            |> Base.decode16!
            |> MlDHT.search(fn(node) ->
             {ip, port} = node
             IO.puts "ip: #{inpsect ip} port: #{port}"
           end)
  """
  @spec search(infohash, fun) :: atom
  defdelegate search(infohash, callback), to: DHTServer.Worker

  @doc ~S"""
  This function needs an infohash as binary and callback function as
  parameter. This function does the same thing as the search/2 function, except
  it sends an announce message to the found peers. This function does not need a
  TCP port which means the announce message sets `:implied_port` to true.

  ## Example
      iex> "3F19B149F53A50E14FC0B79926A391896EABAB6F" ## Ubuntu 15.04
           |> Base.decode16!
           |> MlDHT.search_announce(fn(node) ->
             {ip, port} = node
             IO.puts "ip: #{inspect ip} port: #{port}"
           end)
  """
  @spec search_announce(infohash, fun) :: atom
  defdelegate search_announce(infohash, callback), to: DHTServer.Worker

  @doc ~S"""
  This function needs an infohash as binary, a callback function as parameter,
  and a TCP port as integer. This function does the same thing as the search/2
  function, except it sends an announce message to the found peers.

  ## Example
      iex> "3F19B149F53A50E14FC0B79926A391896EABAB6F" ## Ubuntu 15.04
           |> Base.decode16!
           |> MlDHT.search_announce(fn(node) ->
             {ip, port} = node
             IO.puts "ip: #{inspect ip} port: #{port}"
           end, 6881)
  """
  @spec search_announce(infohash, fun, tcp_port) :: atom
  defdelegate search_announce(infohash, callback, port), to: DHTServer.Worker

end
