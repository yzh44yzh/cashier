defmodule Cashier.Model.Discount do

  defprotocol Strategy do
    alias Cashier.Model

    @spec apply(Strategy.t, Model.price, Model.quantity) :: Model.price
    def apply(strategy, price_per_item, quantity)
  end

  defmodule BuySomeGetOneFreeStrategy do
    alias Cashier.Model

    @type t :: %__MODULE__{
      some: pos_integer
    }

    @enforce_keys [:some]
    defstruct [:some]

    @spec new(pos_integer) :: t
    def new(some \\ 2) do
      %__MODULE__{some: some}
    end

    defimpl Strategy do
      alias Cashier.Model

      @spec apply(BuySomeGetOneFreeStrategy.t, Model.price, Model.quantity) :: Model.price
      def apply(strategy, price_per_item, quantity) do
        %BuySomeGetOneFreeStrategy{some: some} = strategy
        paid_quantity = quantity - div(quantity, some)
        {currency, amount} = price_per_item
        {currency, amount * paid_quantity}
      end
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

    defimpl Strategy do
      alias Cashier.Model

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

  end

  defmodule Registry do
    alias Cashier.Model.Shop.Item

    @type t :: %__MODULE__{
      items: %{Item.id => Strategy.t}
    }

    defstruct [items: %{}]

    @spec new() :: t
    def new() do
      %__MODULE__{}
    end
  end

end
