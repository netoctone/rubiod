module Rubiod

  class Row

    def initialize worksheet, x_row
      @worksheet = worksheet
      @x_row = x_row

      @cell_refs = GappedNumHash.new
      this = self
      cur_index = 0
      @x_row.children.each do |x_cell|
        if rep = x_cell['number-columns-repeated']
          rep = rep.to_i
          @cell_refs.insert cur_index..cur_index+rep-1, Cell.new(this, x_cell)
          cur_index += rep
        else
          @cell_refs.insert cur_index, Cell.new(this, x_cell)
          cur_index += 1
        end
      end
    end

    attr_reader :worksheet

    def repeated?
      @x_row['number-rows-repeated']
    end

    def [] ind
      cell = @cell_refs[ind]
      return nil if cell.no_data?
      cell.first_p_content
    end

    def []= ind, val
    end

  end

end
