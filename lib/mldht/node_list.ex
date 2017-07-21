defmodule MlDHT.NodeList do
  @moduledoc"""
  A genserver holding a list of the IDs for all our DHT nodes
  """

  @name __MODULE__

  use GenServer

  def start_link(node_ids) do
    GenServer.start_link(__MODULE__, node_ids, name: @name)
  end

  def get(), do: GenServer.call(@name, :get)

  def init(node_ids) do 
    {:ok, node_ids}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
  
end