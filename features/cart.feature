@frontend
Feature: Cart

  Scenario: Add an in-stock product
    When I click "Add to cart" on an in-stock product
    Then the cart badge shows 1

  Scenario: Over-stock quantity
    When I try to add more than is available
    Then I see "Only N left"

  Scenario: Update, remove and clear
    Given my cart has items
    When I change a quantity, remove an item and clear the cart
    Then the cart and totals update after each action

  Scenario: Badge shows total item count
    Given my cart has 2 of one product and 3 of another
    Then the header badge shows 5

  Scenario: Cart persists across reload
    Given I added an item
    When I reload the page
    Then the cart still contains the item
