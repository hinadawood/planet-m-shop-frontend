@frontend
Feature: Checkout

  Scenario: Bill summary
    Given my cart has items
    When I open checkout
    Then I see line items and subtotal, shipping, tax and total

  Scenario: Shipping form validation
    When I submit the form with required fields empty
    Then I see inline errors and the order is not submitted

  Scenario: Payment method form
    When I open checkout
    Then I can choose "Credit / Debit card" or "Afterpay"
    And card is preselected

  Scenario: Afterpay note
    When I select Afterpay
    Then I see a pay-in-instalments note
    And Place order sends paymentMethod AFTERPAY

  Scenario: Afterpay unavailable
    Given the total is outside Afterpay limits or the country is unsupported
    Then Afterpay is disabled with a hint

  Scenario: Place order blocked until valid
    Then Place order stays disabled until shipping and payment method are valid

  Scenario: Empty cart
    Given my cart is empty
    When I open checkout
    Then I am sent back to the cart
