defmodule MlDHT.Namespace do

  @name __MODULE__

  @doc """
  Creates a via tuple for naming new and accessing existing processes.
  Takes the desired name (usually @name) and the node_id of the DHT node we're running.
  """
  def name(name, id), do: { :via, Registry, { @name, { name, id } } }

end