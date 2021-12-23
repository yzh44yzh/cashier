defmodule Cashier.Model do

  @type currency :: :EURO_cent | :USD_cent | :GBP_pence
  @type amount :: non_neg_integer
  @type quantity :: non_neg_integer
  @type price :: {currency, amount}

end
