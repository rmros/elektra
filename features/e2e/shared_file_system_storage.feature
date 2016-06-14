@javascript
Feature: Shared File System Storage
  Background:
    Given Test user has accepted terms of use
    Given I visit domain path "identity/home"
    And I log in as test_user
    Then I am redirected to domain path "identity/home"

  Scenario: The Shared File System Storage page is reachable
    When I visit project path "shared-filesystem-storage"
    Then the page status code is successful
    And I see "Shared File System Storage"

