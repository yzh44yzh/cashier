defmodule Cashier do
  alias Cashier.Model
  alias Cashier.Model.Shop, as: S
  alias Cashier.Model.Discount, as: D
  alias Cashier.PrettyPrinter, as: P

  @spec calc_total(S.Cart.t, D.Registry.t) :: Model.price | nil
  def calc_total(cart, _discounts) when map_size(cart.items) == 0, do: nil
  def calc_total(cart, discounts) do
    %S.Item{price: {currency, _}} = hd(Map.keys(cart.items))
    Enum.reduce(
      cart.items,
      {currency, 0},
      fn({item, quantity}, total) ->
        calc_item(item, quantity, discounts)
        |> sum_prices(total)
      end)
  end

  @spec calc_item(S.Item.t, Model.quantity, D.Registry.t) :: Model.price
  def calc_item(item, quantity, discounts) do
    case Map.fetch(discounts.items, item.id) do
      {:ok, strategy} ->
        D.Strategy.apply(strategy, item.price, quantity)
      :error ->
        {currency, amount} = item.price
        {currency, amount * quantity}
    end
  end

  @spec sum_prices(Model.price, Model.price) :: Model.price
  def sum_prices(price1, price2) do
    {currency1, amount1} = price1
    {currency2, amount2} = price2

    if currency1 != currency2 do
      raise Model.CurrencyMismatchError, {currency1, currency2}
    end

    {currency1, amount1 + amount2}
  end

  ## Usage Example

  def example() do
    cart = shopping_cart_example()
    discounts = discount_registry_example()
    total = calc_total(cart, discounts)
    IO.puts(P.print_cart(cart))
    IO.puts("Total: " <> P.print_price(total))
  end

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
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(coffee)
  end

  def discount_registry_example() do
    free = D.BuySomeGetOneFreeStrategy.new(2)
    bulk = D.BulkStrategy.new(3, {:GBP_pence, 450})
    fraction = D.FractionStrategy.new(3, 2, 3)

    D.Registry.new()
    |> D.Registry.add_strategy("GR1", free)
    |> D.Registry.add_strategy("SR1", bulk)
    |> D.Registry.add_strategy("CF1", fraction)
  end

end
