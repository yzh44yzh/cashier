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

  test "BuyOneGetOneFreeStrategy" do
    price = {:GBP_pence, 311}
    strategy = D.BuyOneGetOneFreeStrategy.new(price, 1)
    assert D.Strategy.apply(strategy) ==  price

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 2)
    assert D.Strategy.apply(strategy) ==  price

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 3)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 2}

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 4)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 2}

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 5)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 3}

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 6)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 3}

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 7)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 4}

    strategy = D.BuyOneGetOneFreeStrategy.new(price, 8)
    assert D.Strategy.apply(strategy) == {:GBP_pence, 311 * 4}
  end

end
