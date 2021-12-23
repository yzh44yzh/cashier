defmodule PrettyPrinterTest do
  use ExUnit.Case, async: true
  alias Cashier.PrettyPrinter, as: P
  alias Cashier.Model.Shop, as: S

  test "print price" do
    assert P.print_price({:EURO_cent, 0}) == "€0.00"
    assert P.print_price({:EURO_cent, 1}) == "€0.01"
    assert P.print_price({:EURO_cent, 8}) == "€0.08"
    assert P.print_price({:EURO_cent, 10}) == "€0.10"
    assert P.print_price({:EURO_cent, 25}) == "€0.25"
    assert P.print_price({:EURO_cent, 125}) == "€1.25"
    assert P.print_price({:EURO_cent, 500}) == "€5.00"
    assert P.print_price({:EURO_cent, 520}) == "€5.20"
    assert P.print_price({:EURO_cent, 15022}) == "€150.22"

    assert P.print_price({:USD_cent, 5}) == "$0.05"
    assert P.print_price({:USD_cent, 1037}) == "$10.37"

    assert P.print_price({:GBP_pence, 18}) == "£0.18"
    assert P.print_price({:GBP_pence, 421}) == "£4.21"
  end

  test "print item" do
    tea = %S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}}
    assert P.print_item(tea) == "GR1\tGreen tea\t£3.11"

    strawberries = %S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}}
    assert P.print_item(strawberries) == "SR1\tStrawberries\t£5.00"

    coffee = %S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}}
    assert P.print_item(coffee) == "CF1\tCoffee\t£11.23"
  end

  test "print_cart" do
    tea = %S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}}
    strawberries = %S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}}
    coffee = %S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}}
    cart = S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(strawberries)

    assert P.print_cart(cart) ==
      "CF1\tCoffee\t£11.23 x 3\n" <>
      "GR1\tGreen tea\t£3.11 x 2\n" <>
      "SR1\tStrawberries\t£5.00 x 1"
  end

end
