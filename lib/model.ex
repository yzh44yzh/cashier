defmodule Cashier.Model do

  @type currency :: :EURO_cent | :USD_cent | :GBP_pence
  @type amount :: non_neg_integer
  @type quantity :: non_neg_integer
  @type price :: {currency, amount}

  defmodule CurrencyMismatchError do
    alias Cashier.Model

    defexception [
      :message,
      :currency_needed,
      :currency_received
    ]

    @impl true
    @spec exception({Model.currency, Model.currency}) :: Exception.t
    def exception({currency_needed, currency_received}) do
      %CurrencyMismatchError{
        message: "currency needed: #{currency_needed}, currency_received: #{currency_received}",
        currency_needed: currency_needed,
        currency_received: currency_received
      }
    end
  end

  defmodule PriceLimitError do
    alias Cashier.Model

    defexception [
      :message,
      :price_limit,
      :price_received
    ]

    @impl true
    @spec exception({Model.price, Model.price}) :: Exception.t
    def exception({price_limit, price_received}) do
      %PriceLimitError{
        message: "price #{inspect price_received} should be less than #{inspect price_limit}",
        price_limit: price_limit,
        price_received: price_received
      }
    end
  end

end
