defmodule Cashier.Model.Shop do

  defmodule Item do
    alias Cashier.Model

    @type id :: String.t
    @type t :: %__MODULE__{
      id: id,
      name: String.t,
      price: Model.price
    }

    @enforce_keys [:id, :name, :price]
    defstruct [:id, :name, :price]
  end

  defmodule Cart do
    alias Cashier.Model
    alias Cashier.Model.Shop.Item

    @type t :: %__MODULE__{
      items: %{Item.t => Model.quantity}
    }

    defstruct [items: %{}]

    @spec new() :: t
    def new() do
      %__MODULE__{}
    end

    @spec add_item(t, Item.t) :: t
    def add_item(cart, item) do
      items = Map.update(cart.items, item, 1, fn(q) -> q + 1 end)
      %__MODULE__{cart | items: items}
    end

  end

end
