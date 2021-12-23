defmodule DiscountTest do
  use ExUnit.Case
  alias Cashier.Model
  alias Cashier.Model.Discount, as: D

  test "Buy 2 get 1 free Strategy" do
    price = {:GBP_pence, 311}
    strategy = D.BuySomeGetOneFreeStrategy.new(2)
    assert D.Strategy.apply(strategy, price, 1) == {:GBP_pence, 311}
    assert D.Strategy.apply(strategy, price, 2) == {:GBP_pence, 311}
    assert D.Strategy.apply(strategy, price, 3) == {:GBP_pence, 311 * 2}
    assert D.Strategy.apply(strategy, price, 4) == {:GBP_pence, 311 * 2}
    assert D.Strategy.apply(strategy, price, 5) == {:GBP_pence, 311 * 3}
    assert D.Strategy.apply(strategy, price, 6) == {:GBP_pence, 311 * 3}
    assert D.Strategy.apply(strategy, price, 7) == {:GBP_pence, 311 * 4}
    assert D.Strategy.apply(strategy, price, 8) == {:GBP_pence, 311 * 4}
  end

  test "Buy 3 get 1 free Strategy" do
    price = {:EURO_cent, 500}
    strategy = D.BuySomeGetOneFreeStrategy.new(3)
    assert D.Strategy.apply(strategy, price, 1) == {:EURO_cent, 500}
    assert D.Strategy.apply(strategy, price, 2) == {:EURO_cent, 500 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:EURO_cent, 500 * 2}
    assert D.Strategy.apply(strategy, price, 4) == {:EURO_cent, 500 * 3}
    assert D.Strategy.apply(strategy, price, 5) == {:EURO_cent, 500 * 4}
    assert D.Strategy.apply(strategy, price, 6) == {:EURO_cent, 500 * 4}
    assert D.Strategy.apply(strategy, price, 7) == {:EURO_cent, 500 * 5}
    assert D.Strategy.apply(strategy, price, 8) == {:EURO_cent, 500 * 6}
    assert D.Strategy.apply(strategy, price, 9) == {:EURO_cent, 500 * 6}
    assert D.Strategy.apply(strategy, price, 10) == {:EURO_cent, 500 * 7}
  end

  test "Buy 5 get 1 free Strategy" do
    price = {:USD_cent, 4200}
    strategy = D.BuySomeGetOneFreeStrategy.new(5)
    assert D.Strategy.apply(strategy, price, 1) == {:USD_cent, 4200}
    assert D.Strategy.apply(strategy, price, 2) == {:USD_cent, 4200 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:USD_cent, 4200 * 3}
    assert D.Strategy.apply(strategy, price, 4) == {:USD_cent, 4200 * 4}
    assert D.Strategy.apply(strategy, price, 5) == {:USD_cent, 4200 * 4}
    assert D.Strategy.apply(strategy, price, 6) == {:USD_cent, 4200 * 5}
    assert D.Strategy.apply(strategy, price, 7) == {:USD_cent, 4200 * 6}
    assert D.Strategy.apply(strategy, price, 8) == {:USD_cent, 4200 * 7}
    assert D.Strategy.apply(strategy, price, 9) == {:USD_cent, 4200 * 8}
    assert D.Strategy.apply(strategy, price, 10) == {:USD_cent, 4200 * 8}
  end

  test "Bulk 3 Strategy" do
    price = {:GBP_pence, 500}
    strategy = D.BulkStrategy.new(3, {:GBP_pence, 450})
    assert D.Strategy.apply(strategy, price, 1) == {:GBP_pence, 500}
    assert D.Strategy.apply(strategy, price, 2) == {:GBP_pence, 500 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:GBP_pence, 450 * 3}
    assert D.Strategy.apply(strategy, price, 4) == {:GBP_pence, 450 * 4}
    assert D.Strategy.apply(strategy, price, 5) == {:GBP_pence, 450 * 5}
  end

  test "Bulk 5 Strategy" do
    price = {:GBP_pence, 500}
    strategy = D.BulkStrategy.new(5, {:GBP_pence, 430})
    assert D.Strategy.apply(strategy, price, 1) == {:GBP_pence, 500}
    assert D.Strategy.apply(strategy, price, 2) == {:GBP_pence, 500 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:GBP_pence, 500 * 3}
    assert D.Strategy.apply(strategy, price, 4) == {:GBP_pence, 500 * 4}
    assert D.Strategy.apply(strategy, price, 5) == {:GBP_pence, 430 * 5}
    assert D.Strategy.apply(strategy, price, 6) == {:GBP_pence, 430 * 6}
  end

  test "BulkStrategy exceptions" do
    price = {:GBP_pence, 500}
    strategy = D.BulkStrategy.new(3, {:EURO_cent, 450})
    assert_raise Model.CurrencyMismatchError,
      "currency needed: EURO_cent, currency_received: GBP_pence",
      fn() ->
        D.Strategy.apply(strategy, price, 1)
      end

    strategy = D.BulkStrategy.new(3, {:GBP_pence, 550})
    assert_raise Model.PriceLimitError,
      "price {:GBP_pence, 550} should be less than {:GBP_pence, 500}",
      fn() ->
        D.Strategy.apply(strategy, price, 1)
      end
  end

  test "2/3 FractionStrategy" do
    price = {:GBP_pence, 1123}
    strategy = D.FractionStrategy.new(2, 3, 3)
    assert D.Strategy.apply(strategy, price, 1) == {:GBP_pence, 1123}
    assert D.Strategy.apply(strategy, price, 2) == {:GBP_pence, 1123 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:GBP_pence, div(1123 * 3 * 2, 3)}
    assert D.Strategy.apply(strategy, price, 4) == {:GBP_pence, div(1123 * 4 * 2, 3)}
    assert D.Strategy.apply(strategy, price, 5) == {:GBP_pence, div(1123 * 5 * 2, 3)}
    assert D.Strategy.apply(strategy, price, 6) == {:GBP_pence, div(1123 * 6 * 2, 3)}
  end

  test "3/4 FractionStrategy" do
    price = {:EURO_cent, 1123}
    strategy = D.FractionStrategy.new(3, 4, 3)
    assert D.Strategy.apply(strategy, price, 1) == {:EURO_cent, 1123}
    assert D.Strategy.apply(strategy, price, 2) == {:EURO_cent, 1123 * 2}
    assert D.Strategy.apply(strategy, price, 3) == {:EURO_cent, div(1123 * 3 * 3, 4)}
    assert D.Strategy.apply(strategy, price, 4) == {:EURO_cent, div(1123 * 4 * 3, 4)}
    assert D.Strategy.apply(strategy, price, 5) == {:EURO_cent, div(1123 * 5 * 3, 4)}
    assert D.Strategy.apply(strategy, price, 6) == {:EURO_cent, div(1123 * 6 * 3, 4)}
  end

end
