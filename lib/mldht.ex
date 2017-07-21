defmodule MlDHT do

  @moduledoc ~S"""
  Multinode - MlDHT is an Elixir package based off Florian Adamsky's mainline DHT package.
  It allows creation of multiple DHT nodes for DHT indexing.

  Number of DHT nodes defaults to 1, and can be set in config/config.exs like so:

  ```
  config :mldht,
    num_nodes: 2
  ```
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

  use Application

  import Supervisor.Spec, warn: false

  @doc false
  def start(_type, _arg) do
    Supervisor.start_link(@name, [], name: @name)
  end

  def init([]) do
    # Default to a single node if number not specified in config
    num_nodes = Application.get_env(:mldht, :num_nodes) || 1

    children = [
      supervisor(Registry, [:unique, MlDHT.Namespace]),
      supervisor(MlDHT.Supervisor, [num_nodes])
    ]

    opts = [strategy: :one_for_one, name: MlDHT]

    supervise(children, opts)
  end

  defdelegate new(num), to: MlDHT.Supervisor

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
  def search(infohash, callback) do
    MlDHT.NodeList.get()
    |> Enum.map(& DHTServer.Worker.search(&1, infohash, callback))
  end


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
  def search_announce(infohash, callback) do
    MlDHT.NodeList.get()
    |> Enum.map(& DHTServer.Worker.search_announce(&1, infohash, callback))
  end

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
  def search_announce(infohash, callback, port) do
    MlDHT.NodeList.get()
    |> Enum.map(& DHTServer.Worker.search_announce(&1, infohash, callback, port))
  end

end