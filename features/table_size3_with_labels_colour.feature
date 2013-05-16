Feature: primetable outputs a multiplication table of prime numbers,
         the option -l adds row and column labels to the table. We specify the
         print the multiplication table of the first 3 prime numbers.

@ansi
Scenario: Generate table to stdout
    When I run `primetable -l -c 3` interactively
    Then the output should contain exactly:
    """
    +---+----+----+----+
    |   | \e[1m\e[36m2\e[0m  | \e[1m\e[36m3\e[0m  | \e[1m\e[36m5\e[0m  |
    +---+----+----+----+
    | \e[1m\e[36m2\e[0m | \e[32m4\e[0m  | 6  | 10 |
    +---+----+----+----+
    | \e[1m\e[36m3\e[0m | 6  | \e[32m9\e[0m  | 15 |
    +---+----+----+----+
    | \e[1m\e[36m5\e[0m | 10 | 15 | \e[32m25\e[0m |
    +---+----+----+----+

    """
And the exit status should be 0
