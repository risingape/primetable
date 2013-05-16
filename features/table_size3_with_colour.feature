Feature: primetable outputs a multiplication table of prime numbers,
         the option -l adds row and column labels to the table. We specify the
         print the multiplication table of the first 3 prime numbers.

@ansi
Scenario: Generate table to stdout
    When I run `primetable -c 3` interactively
    Then the output should contain exactly:
    """
    +----+----+----+
    | 4  | \e[1m\e[36m6\e[0m  | \e[1m\e[36m10\e[0m |
    +----+----+----+
    | \e[1m\e[36m6\e[0m  | \e[32m9\e[0m  | 15 |
    +----+----+----+
    | \e[1m\e[36m10\e[0m | 15 | \e[32m25\e[0m |
    +----+----+----+

    """
And the exit status should be 0
