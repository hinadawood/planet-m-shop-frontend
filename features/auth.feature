@frontend
Feature: Registration and login

  Scenario: Register form validation
    When I submit the register form with an invalid email or a short password
    Then I see inline errors and nothing is sent

  Scenario: Successful registration and login
    When I register and log in with valid details
    Then I am redirected to my account page

  Scenario: Wrong credentials
    When I log in with a wrong password
    Then I see "Invalid email or password"

  Scenario: Tokens are not readable by JavaScript
    When I log in
    Then access and refresh tokens exist only in httpOnly cookies

  Scenario: Expired access token is refreshed transparently
    Given my access token has expired
    When I load a protected page
    Then the BFF refreshes the token and the page loads

  Scenario: Protected pages redirect
    Given I am logged out
    When I open /account/orders
    Then I am redirected to /login

  Scenario: Logging in merges the guest cart
    Given I have items in a guest cart
    When I log in
    Then the items appear in my account cart

  Scenario: Logout
    When I log out
    Then the cookies are cleared and protected pages redirect to /login
