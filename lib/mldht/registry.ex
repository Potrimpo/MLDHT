defmodule MlDHT.Registry do

  @name __MODULE__

  def new_name(module, id), do: { :via, Registry, { @name, { module, id } } }

  def lookup(module, id), do: Registry.lookup(@name, {module, id})

end