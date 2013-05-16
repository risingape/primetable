require_relative 'primetable.so'

module PrimeTable
  
  # PrimeTable::PrimeGenerator generates the first n primes. It encapsulates
  # the actual prime number generation algorithms. It implements the strategy
  # pattern to allow for the later addition of other algorithms. The algorithms
  # are instantiated using reflection.
  #
  class PrimeGenerator

    # Generates the first +n+ prime numbers. For example:
    # 
    #   PrimeTable::PrimeGenerator.first(4)
    #   # => [2,3,5,7]
    #
    # Instanciate the actual class implementing the prime generation algorithm
    # by its class name
    #
    # Error handling:
    # if requested algorithm not found throw exception
    # throw exception if class does not exist
    def self.first(n, generatorString="Erastosthenes" )

      # use reflection to find the class
      # we want to search the entire hierarchy
      classes = []

      ObjectSpace.each_object(Class) do |c|
        next unless c.ancestors.include?(self) and (c != self)
        classes <<  c.name.split('::').last
      end

      # find the right class or throw an exception if it does not exist
      index = classes.index generatorString 
      if index
          generator = PrimeTable.const_get(generatorString).new
      else         
         raise NotImplementedError, "Prime generator algorithm " + 
             generatorString + " not implemented!"
      end

      # finally call it
      generator.first(n)
    end
  end

  # PrimeTable::Erastosthenes implements the [Sieve of Erastosthenes](http://en.wikipedia.org/wiki/Sieve_of_Erastosthenes) 
  # to generate prime numbers using a multi-threaded native Ruby C extension.
  class Erastosthenes < PrimeGenerator

    # Generates the first +n+ prime numbers by calling a native C extension.
    # For example:
    # 
    #   PrimeTable::Erastosthenes.first(4)
    #   # => [2,3,5,7]
    #
    def first(n)
        primes = Prime.new.generate(n)
    end

  end

  # Empty class to test the reflection based instantiation by name.
  class DummyGenerator < PrimeGenerator

    # Generates the first +n+ prime numbers. For example:
    # 
    #   PrimeTable::DummyGenerator.first(4)
    #   # => [2,3,5,7]
    #
    def first(n)
        puts "DummyGenerator first called."
        primes = Array.new(n, 1)
    end

  end

  # Empty class to test the reflection based instantiation by name.
  class DummyGenerator2 < DummyGenerator

    # Generates the first +n+ prime numbers. For example:
    # 
    #   PrimeTable::DummyGenerator2.first(4)
    #   # => [2,3,5,7]
    #
    def first(n)
        puts "DummyGenerator2 first called."
        primes = Array.new(n, 1)
    end

  end

end




