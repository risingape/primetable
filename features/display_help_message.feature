Feature: primetable outputs a table of prime numbers
 
  Scenario: App gives a help message
    When I get help for "primetable"
    Then the exit status should be 0
    And the banner should be present
    And there should be a one line summary of what the app does
    And the banner should include the version
    And the banner should document that this app takes options
    And the following options should be documented:
      |colour|
      |label |
      |alg   |
    And the banner should document that this app's arguments are:
      |number_of_primes|optional|
