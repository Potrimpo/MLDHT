defmodule MlDHT.Registry do

  @name __MODULE__

  def add(module, num) do
    Registry.register(@name, module, num)
  end

  # def add(module, num) do
  #   to_string(name) <> to_string(num)
  #   |> String.to_atom
  # end

end