defmodule Cashier do

  alias Cashier.Model
  alias Cashier.Model.Shop, as: S
  alias Cashier.Model.Discount, as: D

  def shopping_cart_example() do
    tea = %S.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    }
    strawberries = %S.Item{
      id: "SR1",
      name: "Strawberries",
      price: {:GBP_pence, 500}
    }
    coffee = %S.Item{
      id: "CF1",
      name: "Coffee",
      price: {:GBP_pence, 1123}
    }

    S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(coffee)
  end

  def discount_registry_example() do
    D.Registry.new()

    raise Model.CurrencyMismatchError, {:EURO_cent, :USD_cent}
  end

end
