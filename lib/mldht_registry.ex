defmodule MlDHT.Registry do

  def id_to_registry(name, num) do
    to_string(name) <> to_string(num)
    |> String.to_atom
  end

end