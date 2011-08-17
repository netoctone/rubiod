module Rubiod

  class Row

    def initialize worksheet, x_row
      @worksheet = worksheet
      @x_row = x_row

      @cell_refs = GappedNumHash.new
      this = self
      cur_index = 0
      @x_row.children.each do |x_cell|
        cell = Cell.new(this, x_cell)
        if rep = cell.repeated?
          @cell_refs.insert cur_index..cur_index+rep-1, cell
          cur_index += rep
        else
          @cell_refs.insert cur_index, cell
          cur_index += 1
        end
      end
    end

    attr_reader :worksheet

    def repeated?
      rep = @x_row['number-rows-repeated']
      rep && rep.to_i
    end

    def [] ind
      @cell_refs[ind].data
    end

    def []= ind, val
      num_or_range, cell = @cell_refs.at ind
      if num_or_range.is_a? Range
        cells = cell.send :insert_split, ind-num_or_range.first, val
        @cell_refs.insert_split ind, cells
        val
      else
        cell.set_data val
      end
    end

    def cellnum
      @cell_refs.last_index + 1
    end

    private

    def insert_after
      @x_row.next = @x_row.ns_copy_with_attrs << @x_row.doc.ns_create_node(
        'table:table-cell', nil, 'table:number-columns-repeated' => cellnum
      )

      Row.new(@worksheet, @x_row.next)
    end

  end

end
