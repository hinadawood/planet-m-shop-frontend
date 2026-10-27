@frontend
Feature: Account and order history

  Scenario: Past orders newest first
    Given I am logged in and have three orders
    When I open /account/orders
    Then the orders are listed newest first with status and total

  Scenario: Order timeline
    When I open an order
    Then I see its events in order, such as placed, paid and shipped

  Scenario: Empty history
    Given I have no orders
    Then I see an empty-state message

  Scenario: History temporarily delayed
    Given an order was paid a moment ago
    Then the order page still shows PAID from the live status

  Scenario: Cancel a pending order
    Given an order is PENDING_PAYMENT
    When I click Cancel
    Then the order shows CANCELLED

  Scenario: Saved addresses
    When I add, edit and delete a shipping address
    Then the list updates after each action
