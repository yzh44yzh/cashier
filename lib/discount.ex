defmodule Cashier.Model.Discount do

  defmodule BuyOneGetOneFreeStrategy do
    alias Cashier.Model

    @type t :: BuyOneGetOneFreeStrategy

    @spec apply(Model.price, Model.quantity) :: Model.price
    def apply(price_per_item, quantity) do
      paid_quantity = div(quantity, 2) + rem(quantity, 2)
      {currency, amount} = price_per_item
      {currency, amount * paid_quantity}
    end
  end

  defmodule BulkStrategy do
    alias Cashier.Model

    @type t :: %__MODULE__{
      bulk_size: pos_integer,
      drop_price: Model.price
    }

    @enforce_keys [:bulk_size, :drop_price]
    defstruct [:bulk_size, :drop_price]

    @spec new(pos_integer, Model.price) :: t
    def new(bulk_size, drop_price) do
      %__MODULE__{
        bulk_size: bulk_size,
        drop_price: drop_price
      }
    end

    @spec apply(BulkStrategy.t, Model.price, Model.quantity) :: Model.price
    def apply(strategy, original_price, quantity) do
      %BulkStrategy{
        bulk_size: bulk_size,
        drop_price: drop_price
      } = strategy

      {drop_currency, drop_amount} = drop_price
      {original_currency, original_amount} = original_price

      if drop_currency != original_currency do
        raise Model.CurrencyMismatchError, {drop_currency, original_currency}
      end

      if drop_amount >= original_amount do
        raise """
        drop price #{inspect drop_price}
        should be less than original price #{inspect original_price}
        """
      end

      if quantity > bulk_size do
        {original_currency, quantity * drop_amount}
      else
        {original_currency, quantity * original_amount}
      end
    end
  end

  defmodule Registry do
    alias Cashier.Model.Shop.Item

    @type strategy :: BuyOneGetOneFreeStrategy.t | BulkStrategy.t
    @type t :: %__MODULE__{
      items: %{Item.id => strategy}
    }

    defstruct [items: %{}]

    @spec new() :: t
    def new() do
      %__MODULE__{}
    end
  end

end
