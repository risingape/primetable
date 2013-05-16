require 'rainbow'
require 'terminal-table'

module PrimeTable

    # <tt>PrimeTable::Decorator</tt> "abstract" base class implementing the
    # [Decorator pattern](http://http://en.wikipedia.org/wiki/Decorator_pattern).
    class Decorator
      
      # The core of the Decorator Pattern is to forward the 
      def initialize(component)
        @component = component
      end

      # Compute the multiplication table.
      # <tt>Decorator#product</tt> raises +NotImplementedError+
      def product
         raise NotImplementedError, "base class called"
      end

    end

    class Headings < Decorator

      def product
          column_headings = [nil].concat @component.getb
          array_with_row_headings = @component.geta.zip(@component.product).map &:flatten
          array_with_row_headings.unshift column_headings
      end

    end

    class Colour < Decorator

      def product

        # for aruba testing purposes only:
        # if we are not writing to STDOUT, rainbao strips all the colour out.
        # Depending on the environment variable "FORCE_COLOURS" we force 
        # rainbow to colour the output regardless of the output stream.
        if ENV["FORCE_COLORS"] == "TRUE" 
          Sickill::Rainbow.enabled = true
        end

        # deep copy of every element since a string is just an object
        # this is a design choice to make the bahaviour of all decorators consistent.
        array_to_colour = @component.product.inject([]) { |a,element| a << element.dup }

        array_to_colour.length.times do |r|
          array_to_colour.length.times do |c|
            array_to_colour[r][c] = array_to_colour[r][c].to_s.bright.color :cyan if r == 0 and c > 0
            array_to_colour[r][c] = array_to_colour[r][c].to_s.bright.color :cyan if r > 0 and c == 0
            array_to_colour[r][c] = array_to_colour[r][c].to_s.color :green if r > 0 and r == c
          end
        end
 
        array_to_colour
      end

    end

    class Table < Decorator
 
      def product
        array_to_format = @component.product
        table = Terminal::Table.new do |t|
          # add each row apart from the last one with a separator
          array_to_format[0..-2].each do |row|
            t.add_row row
            t.add_separator
          end

          # add the last row without a separator
          t.add_row array_to_format.last
        end
    
        table
      end

    end

end


