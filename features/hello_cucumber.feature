Feature: Hello Cucumber
  As a product manager
  I want our users to be greeted when they visit our site
  So that they have a better experience

  Scenario: User sees the welcome message
    When I go to the homepage
    Then I should see the welcome message
