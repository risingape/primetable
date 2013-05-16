require 'primetable'

describe PrimeTable::Colour do
  table = PrimeTable::TensorProduct.new([1,2,3], [1,2,3,4])
  colourTable = PrimeTable::Colour.new(table)
  
  it 'highlight row and column lables - decorate multiple times' do
    
    # our decorator makes a deep copy of the array
    # this ensures that the colouring is only applied once
    colouredTable = colourTable.product
    colouredTable = colourTable.product
    colouredTable = colourTable.product
    
    colouredTable[0][1].should eql '2'.bright.color :cyan
    colouredTable[0][2].should eql '3'.bright.color :cyan
  end

  it 'element 0,0 and non-diagonal elemets should not be highlighted' do
    colouredTable = colourTable.product
    
    colouredTable[0][0].should eql 1
    colouredTable[1][2].should eql 6
  end

  it 'highlight the diagonal' do
    colouredTable = colourTable.product

    colouredTable[1][1].should eql '4'.color :green
    colouredTable[2][2].should eql '9'.color :green
  end

end
