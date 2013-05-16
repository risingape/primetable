Feature: primetable outputs a table of prime numbers
          An error message should be given if we supply a non-integer argument.
          The exit status should be 1.

Scenario: Generate table to stdout
    When I run `primetable 6f`
    Then the output should contain "Invalid argument: [number_of_primes] has to be an integer. Use -h or --help for usage information."
    And the exit status should be 1
