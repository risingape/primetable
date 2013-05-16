require 'primetable'

describe PrimeTable::Decorator do 
 

  it 'Headings decorator' do
    table = PrimeTable::TensorProduct.new([1,2,3], [1,2,3, 4])
    decoratedTable = PrimeTable::Headings.new(table)
    decoratedTable.product.should eql [[nil,1,2,3,4],
                                  [1,1,2,3,4],
                                  [2,2,4,6,8],
                                  [3,3,6,9,12]]
  end

  it 'Table decorator' do
    st  = <<-EOS
+---+---+
| 1 | 2 |
+---+---+
| 2 | 4 |
+---+---+
EOS
    table = PrimeTable::TensorProduct.new([1,2], [1,2])
    decoratedTable = PrimeTable::Table.new(table)
    tmp = decoratedTable.product.to_s
    tmp.strip.should eql st.strip

  end

end

