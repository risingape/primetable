module PrimeTable

  # class members:
  # vectorA defines the rows
  # vectorB defines the columns
  # tensorProduct = vectorA vectorB^T

  class TensorProduct


    def initialize(vectorA, vectorB = vectorA)
        @vectorA = vectorA.to_a
        @vectorB = vectorB.to_a

        if @vectorA.length == 0 or @vectorB.length == 0
            # throw exception
        end 
    end

    def geta
        @vectorA
    end

    def getb
        @vectorB
    end

    def product
        @tensorProduct ||= @vectorA.product(@vectorB).map{|i, j| i * j}.each_slice(@vectorB.length).to_a
    end

  end

end
