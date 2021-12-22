defmodule ModelTest do
  use ExUnit.Case
  alias Cashier.Model.Shop, as: S

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
end
