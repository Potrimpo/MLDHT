defmodule MlDHT.Namespace do

  @name __MODULE__

  def name(module, id), do: { :via, Registry, { @name, { module, id } } }

  def lookup(module, id), do: Registry.lookup(@name, {module, id})

end