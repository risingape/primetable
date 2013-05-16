Feature: primetable outputs a multiplication table of prime numbers,
         the option -l adds row and column labels to the table. We specify the
         print the multiplication table of the first 3 prime numbers.

Scenario: Generate table to stdout
    When I run `primetable -l 3` interactively
    Then the output should contain exactly:
    """
    +---+----+----+----+
    |   | 2  | 3  | 5  |
    +---+----+----+----+
    | 2 | 4  | 6  | 10 |
    +---+----+----+----+
    | 3 | 6  | 9  | 15 |
    +---+----+----+----+
    | 5 | 10 | 15 | 25 |
    +---+----+----+----+

    """
And the exit status should be 0
