defmodule Cashier.Model do

  @type currency :: :EURO_cent | :USD_cent | :GBP_pence
  @type amount :: non_neg_integer
  @type quantity :: non_neg_integer
  @type money :: {currency, amount}

  defmodule Shop do

    defmodule Item do
      alias Cashier.Model

      @type t :: %__MODULE__{
        id: String.t,
        name: String.t,
        price: Model.money
      }

      @enforce_keys [:id, :name, :price]
      defstruct [:id, :name, :price]
    end

    defmodule Cart do
      alias Cashier.Model

      @type t :: %__MODULE__{
        items: %{Model.Shop.Item.t => Model.quantity}
      }

      defstruct [items: %{}]

      @spec new() :: t
      def new() do
        %__MODULE__{}
      end

      @spec add_item(t, Model.Shop.Item.t) :: t
      def add_item(cart, item) do
        Map.update(cart, item, 1, fn(q) -> q + 1 end)
      end

    end

  end

end
