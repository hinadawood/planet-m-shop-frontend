@frontend
Feature: Catalogue and category pills

  Scenario: Show all products
    Given active products exist
    When I open the catalogue
    Then I see each product's name, image and price

  Scenario: Category pills
    When I open the catalogue
    Then I see pills "All", "Bedroom", "Dining", "Living" and "Outdoor"

  Scenario: Filter by pill
    When I click the "Living" pill
    Then only Living products are shown
    And the pill is marked active with aria-pressed
    And the URL contains "?category=living"

  Scenario: Clear the filter
    Given the "Living" pill is active
    When I click "All" or the active pill again
    Then all products are shown

  Scenario: Pills are accessible and responsive
    Then pills are reachable by keyboard and scroll horizontally on small screens

  Scenario: Empty category
    Given a category has no products
    When I click its pill
    Then an empty-state message is shown and the pill stays selected

  Scenario: Out of stock product
    Given a product has no available stock
    Then it shows an "Out of stock" badge and a disabled Add button

  Scenario: Loading and error states
    When the API is slow
    Then a spinner is shown
    When the API fails
    Then an error banner with a Retry button is shown
