defmodule CashierTest do
  use ExUnit.Case, async: true
  alias Cashier.Model
  alias Cashier.Model.Shop, as: S
  alias Cashier.Model.Discount, as: D

  setup_all do
    state = %{
      items: %{
        gr: %S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}},
        sr: %S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}},
        cf: %S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}},
        mf: %S.Item{id: "MF1", name: "Muffin", price: {:GBP_pence, 150}},
        ps: %S.Item{id: "PS1", name: "Pasta", price: {:GBP_pence, 300}}
      },
      discounts: %{
        free_2: D.BuySomeGetOneFreeStrategy.new(2),
        bulk_3: D.BulkStrategy.new(3, {:GBP_pence, 450}),
        fraction_3: D.FractionStrategy.new(3, 2, 3),
        fraction_4: D.FractionStrategy.new(4, 4, 5)
      }
    }
    {:ok, state}
  end

  test "sum prices" do
    price1 = {:GBP_pence, 100}
    price2 = {:GBP_pence, 500}
    price3 = {:USD_cent, 250}
    price4 = {:USD_cent, 600}

    assert Cashier.sum_prices(price1, price2) == {:GBP_pence, 600}
    assert Cashier.sum_prices(price3, price4) == {:USD_cent, 850}
  end

  test "sum prices exception" do
    price1 = {:GBP_pence, 100}
    price2 = {:USD_cent, 250}

    assert_raise Model.CurrencyMismatchError,
      "currency needed: GBP_pence, currency_received: USD_cent",
    fn() ->
      Cashier.sum_prices(price1, price2)
    end
  end

  test "calc item", state do
    discounts = D.Registry.new()
    |> D.Registry.add_strategy("GR1", state.discounts.free_2)
    |> D.Registry.add_strategy("SR1", state.discounts.bulk_3)
    |> D.Registry.add_strategy("CF1", state.discounts.fraction_4)

    assert Cashier.calc_item(state.items.gr, 1, discounts) == {:GBP_pence, 311}
    assert Cashier.calc_item(state.items.gr, 2, discounts) == {:GBP_pence, 311}
    assert Cashier.calc_item(state.items.gr, 3, discounts) == {:GBP_pence, 311 * 2}
    assert Cashier.calc_item(state.items.gr, 4, discounts) == {:GBP_pence, 311 * 2}
    assert Cashier.calc_item(state.items.gr, 5, discounts) == {:GBP_pence, 311 * 3}

    assert Cashier.calc_item(state.items.sr, 1, discounts) == {:GBP_pence, 500}
    assert Cashier.calc_item(state.items.sr, 2, discounts) == {:GBP_pence, 500 * 2}
    assert Cashier.calc_item(state.items.sr, 3, discounts) == {:GBP_pence, 450 * 3}
    assert Cashier.calc_item(state.items.sr, 4, discounts) == {:GBP_pence, 450 * 4}
    assert Cashier.calc_item(state.items.sr, 5, discounts) == {:GBP_pence, 450 * 5}

    assert Cashier.calc_item(state.items.cf, 1, discounts) == {:GBP_pence, 1123}
    assert Cashier.calc_item(state.items.cf, 2, discounts) == {:GBP_pence, 1123 * 2}
    assert Cashier.calc_item(state.items.cf, 3, discounts) == {:GBP_pence, 1123 * 3}
    assert Cashier.calc_item(state.items.cf, 4, discounts) == {:GBP_pence, div(1123 * 4 * 4, 5)}
    assert Cashier.calc_item(state.items.cf, 5, discounts) == {:GBP_pence, div(1123 * 5 * 4, 5)}

    assert Cashier.calc_item(state.items.ps, 1, discounts) == {:GBP_pence, 300}
    assert Cashier.calc_item(state.items.ps, 2, discounts) == {:GBP_pence, 300 * 2}
    assert Cashier.calc_item(state.items.ps, 3, discounts) == {:GBP_pence, 300 * 3}
    assert Cashier.calc_item(state.items.ps, 4, discounts) == {:GBP_pence, 300 * 4}
    assert Cashier.calc_item(state.items.ps, 5, discounts) == {:GBP_pence, 300 * 5}
  end

  test "calc cart", state do
    discounts = D.Registry.new()
    |> D.Registry.add_strategy("GR1", state.discounts.free_2)
    |> D.Registry.add_strategy("SR1", state.discounts.bulk_3)
    |> D.Registry.add_strategy("CF1", state.discounts.fraction_3)

    tea = state.items.gr
    strawberries = state.items.sr
    coffee = state.items.cf

    cart = S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(coffee)
    assert Cashier.calc_total(cart, discounts) == {:GBP_pence, 2245}

    cart = S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(tea)
    assert Cashier.calc_total(cart, discounts) == {:GBP_pence, 311}

    cart = S.Cart.new()
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(strawberries)
    assert Cashier.calc_total(cart, discounts) == {:GBP_pence, 1661}

    cart = S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(strawberries)
    |> S.Cart.add_item(coffee)
    |> S.Cart.add_item(coffee)
    assert Cashier.calc_total(cart, discounts) == {:GBP_pence, 3057}

    muffin = state.items.mf
    pasta = state.items.ps

    cart = S.Cart.new()
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(muffin)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(pasta)
    |> S.Cart.add_item(tea)
    |> S.Cart.add_item(muffin)
    |> S.Cart.add_item(tea)
    assert Cashier.calc_total(cart, discounts) == {:GBP_pence, 1222}
  end

  test "calc cart, invalid bulk", state do
    discounts = D.Registry.new()
    |> D.Registry.add_strategy("PS1", state.discounts.bulk_3)
    cart = S.Cart.new()
    |> S.Cart.add_item(state.items.ps)

    assert_raise Model.PriceLimitError,
      "price {:GBP_pence, 450} should be less than {:GBP_pence, 300}",
      fn() ->
        Cashier.calc_total(cart, discounts)
      end
  end

  test "calc cart, invalid currency", state do
    discounts = D.Registry.new()
    muffin = state.items.mf
    euro_muffin = %S.Item{id: "MF1", name: "Muffin", price: {:EURO_cent, 150}}
    cart = S.Cart.new()
    |> S.Cart.add_item(muffin)
    |> S.Cart.add_item(euro_muffin)

    assert_raise Model.CurrencyMismatchError,
      "currency needed: GBP_pence, currency_received: EURO_cent",
      fn() ->
        Cashier.calc_total(cart, discounts)
      end
  end

end
