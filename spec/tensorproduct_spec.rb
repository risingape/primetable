require 'primetable'

describe PrimeTable::TensorProduct do
 
  it 'tensor product of a vector with itself' do
    table = PrimeTable::TensorProduct.new([1, 2, 3])
    table.product.should eql [[1,2,3],
                                  [2,4,6],
                                  [3,6,9]]
  end

  it 'tensor product of two vectors' do
    table = PrimeTable::TensorProduct.new([1, 2, 3], [1, 1, 1])
    table.product.should eql [[1,1,1],
                                  [2,2,2],
                                  [3,3,3]]
  end

  it 'non square product' do
    table = PrimeTable::TensorProduct.new([1, 2, 3], [1, 1, 1,1])
    table.product.should eql [[1,1,1,1],
                                  [2,2,2,2],
                                  [3,3,3,3]]
  end

  it 'non square product' do
    table = PrimeTable::TensorProduct.new([1, 2, 3, 4], [1, 1, 1])
    table.product.should eql [[1,1,1],
                                  [2,2,2],
                                  [3,3,3],
                                  [4,4,4]]
  end

end
