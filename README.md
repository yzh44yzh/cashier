# Cashier

Simple cashier function that adds products to a cart and displays the total price.

## Products Example

| Product code | Name         | Price  |
| ------------ | ------------ | ------ |
| GR1          | Green tea    |  £3.11 |
| SR1          | Strawberries |  £5.00 |
| CF1          | Coffee       | £11.23 |



## Special Conditions

● The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a rule to do this.

● The COO, though, likes low prices and wants people buying strawberries to get a price discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50 per strawberry.

● The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop to two thirds of the original price.

Our check-out can scan items in any order, and because the CEO and COO change their minds often, it needs to be flexible regarding our pricing rules.


## Test Data

**Shopping cart**: GR1, SR1, GR1, GR1, CF1. Total price: £22.45

**Shopping cart**: GR1, GR1. Total price: £3.11

**Shopping cart**: SR1, SR1, GR1, SR1, Total price: £16.61

**Shopping cart**: GR1, CF1, SR1, CF1, CF1, Total price: £30.57


## Usage Example

Create products:

```elixir
iex(1)> alias Cashier.Model.Shop, as: S
Cashier.Model.Shop
iex(2)> tea = %S.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}}
%Cashier.Model.Shop.Item{id: "GR1", name: "Green tea", price: {:GBP_pence, 311}}
iex(3)> strawberries = %S.Item{id: "SR1", name: "Strawberries", price: {:GBP_pence, 500}}
%Cashier.Model.Shop.Item{
  id: "SR1",
  name: "Strawberries",
  price: {:GBP_pence, 500}
}
iex(4)> coffee = %S.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}}
%Cashier.Model.Shop.Item{id: "CF1", name: "Coffee", price: {:GBP_pence, 1123}}
```

Put them into the shopping cart:

```elixir
iex(5)> cart = S.Cart.new()
%Cashier.Model.Shop.Cart{items: %{}}
iex(6)> cart = S.Cart.add_item(cart, tea)
%Cashier.Model.Shop.Cart{
  items: %{
    %Cashier.Model.Shop.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    } => 1
  }
}
iex(7)> cart = S.Cart.add_item(cart, strawberries)
%Cashier.Model.Shop.Cart{
  items: %{
    %Cashier.Model.Shop.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    } => 1,
    %Cashier.Model.Shop.Item{
      id: "SR1",
      name: "Strawberries",
      price: {:GBP_pence, 500}
    } => 1
  }
}
iex(8)> cart = S.Cart.add_item(cart, tea)
%Cashier.Model.Shop.Cart{
  items: %{
    %Cashier.Model.Shop.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    } => 2,
    %Cashier.Model.Shop.Item{
      id: "SR1",
      name: "Strawberries",
      price: {:GBP_pence, 500}
    } => 1
  }
}
iex(9)> cart = S.Cart.add_item(cart, tea)
%Cashier.Model.Shop.Cart{
  items: %{
    %Cashier.Model.Shop.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    } => 3,
    %Cashier.Model.Shop.Item{
      id: "SR1",
      name: "Strawberries",
      price: {:GBP_pence, 500}
    } => 1
  }
}
iex(10)> cart = S.Cart.add_item(cart, coffee)
%Cashier.Model.Shop.Cart{
  items: %{
    %Cashier.Model.Shop.Item{
      id: "CF1",
      name: "Coffee",
      price: {:GBP_pence, 1123}
    } => 1,
    %Cashier.Model.Shop.Item{
      id: "GR1",
      name: "Green tea",
      price: {:GBP_pence, 311}
    } => 3,
    %Cashier.Model.Shop.Item{
      id: "SR1",
      name: "Strawberries",
      price: {:GBP_pence, 500}
    } => 1
  }
}

```

Create discount strategies:

```elixir
iex(14)> alias Cashier.Model.Discount, as: D
Cashier.Model.Discount
iex(15)> free = D.BuySomeGetOneFreeStrategy.new(2)
%Cashier.Model.Discount.BuySomeGetOneFreeStrategy{some: 2}
iex(16)> bulk = D.BulkStrategy.new(3, {:GBP_pence, 450})
%Cashier.Model.Discount.BulkStrategy{
  bulk_size: 3,
  drop_price: {:GBP_pence, 450}
}
iex(17)> fraction = D.FractionStrategy.new(3, 2, 3)
%Cashier.Model.Discount.FractionStrategy{
  denominator: 3,
  numerator: 2,
  quantity_limit: 3
}
```

Bind strategies to the product ids:

```elixir
iex(18)> discounts = D.Registry.new()
%Cashier.Model.Discount.Registry{items: %{}}
iex(19)> discounts = D.Registry.add_strategy(discounts, "GR1", free)
%Cashier.Model.Discount.Registry{
  items: %{"GR1" => %Cashier.Model.Discount.BuySomeGetOneFreeStrategy{some: 2}}
}
iex(20)> discounts = D.Registry.add_strategy(discounts, "SR1", bulk)
%Cashier.Model.Discount.Registry{
  items: %{
    "GR1" => %Cashier.Model.Discount.BuySomeGetOneFreeStrategy{some: 2},
    "SR1" => %Cashier.Model.Discount.BulkStrategy{
      bulk_size: 3,
      drop_price: {:GBP_pence, 450}
    }
  }
}
iex(21)> discounts = D.Registry.add_strategy(discounts, "CF1", fraction)
%Cashier.Model.Discount.Registry{
  items: %{
    "CF1" => %Cashier.Model.Discount.FractionStrategy{
      denominator: 3,
      numerator: 2,
      quantity_limit: 3
    },
    "GR1" => %Cashier.Model.Discount.BuySomeGetOneFreeStrategy{some: 2},
    "SR1" => %Cashier.Model.Discount.BulkStrategy{
      bulk_size: 3,
      drop_price: {:GBP_pence, 450}
    }
  }
}
```

Calculate the total price:

```elixir
iex(23)> price = Cashier.calc_total(cart, discounts)
{:GBP_pence, 2245}
iex(24)> alias Cashier.PrettyPrinter, as: P
Cashier.PrettyPrinter
iex(25)> IO.puts(P.print_cart(cart))
CF1     Coffee  £11.23 x 1
GR1     Green tea       £3.11 x 3
SR1     Strawberries    £5.00 x 1
:ok
iex(26)> IO.puts("Total: " <> P.print_price(price))
Total: £22.45
:ok
```
