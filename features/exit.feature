Feature: primetable outputs a table of prime numbers

Scenario: Generate table to stdout
    When I run `primetable`
    Then the exit status should be 0
