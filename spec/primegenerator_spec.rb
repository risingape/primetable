require 'mathn'
require 'primetable'

describe PrimeTable::PrimeGenerator do
  it 'generates the first 1000 prime numbers' do
    PrimeTable::PrimeGenerator.first(1000).should eql Prime.first(1000)
    PrimeTable::PrimeGenerator.first(1000, 'Erastosthenes').should eql Prime.first(1000)
  end

  it 'algorithm blah does not exist and raises NotImplementedError' do
    primes = lambda { PrimeTable::PrimeGenerator.first(1000, 'blah') }
    primes.should raise_error
  end

  it 'load class implementing algorithm DummyGenerator and DummyGenerator2' do
    PrimeTable::PrimeGenerator.first(10, 'DummyGenerator').should eql Array.new(10, 1)
    PrimeTable::PrimeGenerator.first(10, 'DummyGenerator2').should eql Array.new(10, 1)
  end

end
