# PrimeTable

Simple command line tool to print prime number multiplication tables.

Prime table prints the multiplication table of the first n prime numbers where n has to be > 2.

Features implemented
 * Compute primes with a multi-threaded native C implementation of the Sieve of
   Erastosthenes using POSIX threads (pthreads),
 * Vectorisation of the inner most loop using SSE instructions,
 * Other prime generation algorithm just need to be implemented as a subclass
   of <tt>PrimeTable::PrimeGenerator</tt>. No further changes are necessary,
   we automatically find the new class using reflection,
 * Decorators implemented so far:
   - <tt>PrimeTable::Headings</tt> adds headings to the table,
   - <tt>PrimeTable::Colour</tt> colours the first row and column as well as
     the diagonal,
   - <tt>PrimeTable::Table</tt> adds column and row seperators,
 * Accepts input from STDIN.

## Build Status

To be done.

## Installation

Add this line to your application's Gemfile:

    $ bundle install
    
    $ gem build primetable.gemspec

    $ gem install primetable --no-format-executable

Optional, run the unit tests:
    $ bundle exec rspec spec

Optional, run the behavioural tests:
    $bundle exec cucumber features

(Note: the tests require the development dependencies)

## Help

    primetable --help
    gem man primetable

    [RDoc](http://)

## Usage

    Usage: primetable [options] [number_of_primes]

    Options:
    -h, --help                       Show command line help
    -c, --colour                      Print a coloured table
    -l, --label                      Print row and column labels
    -a, --alg VAL                    Erastosthenes or Atkins sieve algorithm
        --log-level LEVEL            Set the logging level
                                     (debug|info|warn|error|fatal)
                                     (Default: info)
    Examples

    primetable            # prints a multiplication table of the first 10 primes
    primetable 11         # prints out a table of the first 11 primes
    echo 4 | primetable   # takes input argument from STDIN

## Contributing

    1. Fork it
    2. Create your feature branch (`git checkout -b my-new-feature`)
    3. Commit your changes (`git commit -am 'Added some feature'`)
    4. Push to the branch (`git push origin my-new-feature`)
    5. Create new Pull Request
