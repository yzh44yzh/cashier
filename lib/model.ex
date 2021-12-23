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

end
