defmodule Cashier do

  alias Cashier.Model.Shop, as: S

  def shopping_cart_example() do
    S.Cart.new()
    |> S.Cart.add_item(%S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}})
    |> S.Cart.add_item(%S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}})
    |> S.Cart.add_item(%S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}})
    |> S.Cart.add_item(%S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}})
  end

end
