@frontend
Feature: Payment redirect and idempotency

  Scenario: Redirect to Stripe
    When I place the order
    Then the browser is redirected to the Stripe-hosted page

  Scenario: Double click sends one request
    When I double-click Place order
    Then one request is sent and the button is disabled while pending

  Scenario: Network retry reuses the key
    When the request is retried after a network error
    Then the same Idempotency-Key is sent

  Scenario: New key after terminal failure or cart change
    When the order fails terminally or the cart changes
    Then a new Idempotency-Key is generated

  Scenario: Success page
    Given the order is PAID
    When I land on the success page
    Then I see the order confirmation
    And while the order is pending I see "processing"

  Scenario: Cancel page
    When I land on the cancel page
    Then I can go back to my cart
