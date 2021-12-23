defmodule Cashier.PrettyPrinter do
  alias Cashier.Model
  alias Cashier.Model.Shop, as: S

  @spec print_currency(Model.currency) :: String.t
  def print_currency(:EURO_cent), do: "€"
  def print_currency(:USD_cent), do: "$"
  def print_currency(:GBP_pence), do: "£"

  @spec print_price(Model.price) :: String.t
  def print_price({currency, amount}) do
    currency_str = print_currency(currency)
    d = div(amount, 100)
    r = rem(amount, 100)
    amount_str = :io_lib.format("~B.~2..0B", [d, r]) |> to_string()
    currency_str <> amount_str
  end

  @spec print_item(S.Item.t) :: String.t
  def print_item(item) do
    item.id <> "\t" <> item.name <> "\t" <> print_price(item.price)
  end

  @spec print_cart(S.Cart.t) :: String.t
  def print_cart(cart) do
    cart.items
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(
           fn({item, quantity}) ->
               print_item(item) <> " x " <> to_string(quantity)
           end)
    |> Enum.join("\n")
  end

end
