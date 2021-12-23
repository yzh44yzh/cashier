defmodule ModelTest do
  use ExUnit.Case
  alias Cashier.Model.Shop, as: S
  alias Cashier.Model.Discount, as: D

  test "shopping cart" do
    tea = %S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}}
    strawberries = %S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}}
    coffee = %S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}}

    cart = S.Cart.new()
    assert cart == %S.Cart{items: %{}}

    cart = S.Cart.add_item(cart, tea)
    assert cart == %S.Cart{
      items: %{tea => 1}
    }

    cart = S.Cart.add_item(cart, tea)
    assert cart == %S.Cart{
      items: %{tea => 2}
    }

    cart = S.Cart.add_item(cart, coffee)
    assert cart == %S.Cart{
      items: %{tea => 2, coffee => 1}
    }

    cart = S.Cart.add_item(cart, strawberries)
    assert cart == %S.Cart{
      items: %{tea => 2, coffee => 1, strawberries => 1}
    }

    cart = S.Cart.add_item(cart, strawberries)
    assert cart == %S.Cart{
      items: %{tea => 2, coffee => 1, strawberries => 2}
    }

    cart = S.Cart.add_item(cart, tea)
    assert cart == %S.Cart{
      items: %{tea => 3, coffee => 1, strawberries => 2}
    }
  end

  test "Buy 2 get 1 free Strategy" do
    alias D.BuySomeGetOneFreeStrategy, as: S

    price = {:GBP_pence, 311}
    strategy = S.new(2)
    assert S.apply(strategy, price, 1) == {:GBP_pence, 311}
    assert S.apply(strategy, price, 2) == {:GBP_pence, 311}
    assert S.apply(strategy, price, 3) == {:GBP_pence, 311 * 2}
    assert S.apply(strategy, price, 4) == {:GBP_pence, 311 * 2}
    assert S.apply(strategy, price, 5) == {:GBP_pence, 311 * 3}
    assert S.apply(strategy, price, 6) == {:GBP_pence, 311 * 3}
    assert S.apply(strategy, price, 7) == {:GBP_pence, 311 * 4}
    assert S.apply(strategy, price, 8) == {:GBP_pence, 311 * 4}
  end

  test "Buy 3 get 1 free Strategy" do
    alias D.BuySomeGetOneFreeStrategy, as: S

    price = {:EURO_cent, 500}
    strategy = S.new(3)
    assert S.apply(strategy, price, 1) == {:EURO_cent, 500}
    assert S.apply(strategy, price, 2) == {:EURO_cent, 500 * 2}
    assert S.apply(strategy, price, 3) == {:EURO_cent, 500 * 2}
    assert S.apply(strategy, price, 4) == {:EURO_cent, 500 * 3}
    assert S.apply(strategy, price, 5) == {:EURO_cent, 500 * 4}
    assert S.apply(strategy, price, 6) == {:EURO_cent, 500 * 4}
    assert S.apply(strategy, price, 7) == {:EURO_cent, 500 * 5}
    assert S.apply(strategy, price, 8) == {:EURO_cent, 500 * 6}
    assert S.apply(strategy, price, 9) == {:EURO_cent, 500 * 6}
    assert S.apply(strategy, price, 10) == {:EURO_cent, 500 * 7}
  end

  test "Buy 5 get 1 free Strategy" do
    alias D.BuySomeGetOneFreeStrategy, as: S

    price = {:USD_cent, 4200}
    strategy = S.new(5)
    assert S.apply(strategy, price, 1) == {:USD_cent, 4200}
    assert S.apply(strategy, price, 2) == {:USD_cent, 4200 * 2}
    assert S.apply(strategy, price, 3) == {:USD_cent, 4200 * 3}
    assert S.apply(strategy, price, 4) == {:USD_cent, 4200 * 4}
    assert S.apply(strategy, price, 5) == {:USD_cent, 4200 * 4}
    assert S.apply(strategy, price, 6) == {:USD_cent, 4200 * 5}
    assert S.apply(strategy, price, 7) == {:USD_cent, 4200 * 6}
    assert S.apply(strategy, price, 8) == {:USD_cent, 4200 * 7}
    assert S.apply(strategy, price, 9) == {:USD_cent, 4200 * 8}
    assert S.apply(strategy, price, 10) == {:USD_cent, 4200 * 8}
  end

end
