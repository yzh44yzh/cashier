defmodule Cashier.Model.Discount do

  defprotocol Strategy do
    alias Cashier.Model

    @spec apply(Strategy.t) :: Model.price
    def apply(strategy)
  end

  defmodule BuyOneGetOneFreeStrategy do
    alias Cashier.Model

    @type t :: %__MODULE__{
      price: Model.price,
      quantity: Model.quantity
    }

    @enforce_keys [:price, :quantity]
    defstruct [:price, :quantity]

    @spec new(Model.price, Model.quantity) :: t
    def new(price, quantity) do
      %__MODULE__{price: price, quantity: quantity}
    end

    defimpl Strategy do
      @spec apply(BuyOneGetOneFreeStrategy.t) :: Model.price
      def apply(strategy) do
        %BuyOneGetOneFreeStrategy{price: price_per_item, quantity: quantity} = strategy
        paid_quantity = div(quantity, 2) + rem(quantity, 2)
        {currency, amount} = price_per_item
        {currency, amount * paid_quantity}
      end
    end
  end

  defmodule Registry do
    alias Cashier.Model.Shop.Item

    @type t :: %__MODULE__{
      items: %{Item.id => Strategy}
    }

    defstruct [items: %{}]

    @spec new() :: t
    def new() do
      %__MODULE__{}
    end
  end

end
