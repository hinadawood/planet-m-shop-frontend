@frontend
Feature: BFF and server-side rendering

  Scenario: Product list is server-rendered
    When the products page HTML is requested
    Then it contains product names and prices without client JavaScript

  Scenario: Product detail is server-rendered with metadata
    When a product detail page is requested
    Then the HTML contains the title and description metadata
    And an unknown id renders the 404 page

  Scenario: BFF proxies products and maps DTOs
    When the browser calls GET /api/products
    Then the backend is called and the response uses the UI model

  Scenario: BFF serves categories for the pills
    When the browser calls GET /api/categories
    Then the response lists Bedroom, Dining, Living and Outdoor

  Scenario Outline: BFF maps backend errors
    Given the backend answers <backend>
    When the browser calls the BFF
    Then the BFF answers <bff> with a friendly message
    Examples:
      | backend | bff |
      | 404     | 404 |
      | 409     | 409 |
      | 400     | 400 |
      | 429     | 429 |

  Scenario: Secrets are never exposed
    Then BFF responses contain neither the backend URL nor Stripe secrets

  Scenario: Cart session cookie
    When the first cart write succeeds
    Then an httpOnly cart-session cookie is set and forwarded on later calls

  Scenario: Invalid payloads are rejected before the backend
    When the browser posts an invalid payload
    Then the BFF answers 400 without calling the backend

  Scenario: Product change revalidates SSR pages
    When a product is changed through the BFF
    Then the "products" cache tag is revalidated

  Scenario: Client IP and request id are forwarded to the gateway
    When the browser calls any BFF route
    Then the backend call carries X-Forwarded-For with the shopper's IP and an X-Request-Id

  Scenario: Rate limit is shown as a friendly message
    Given the gateway answers 429 with Retry-After
    When the browser calls the BFF
    Then the UI shows "Too many requests, please try again shortly"
