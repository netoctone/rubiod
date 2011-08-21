module Rubiod

  class Row

    def initialize worksheet, x_row
      @worksheet = worksheet
      @x_row = x_row

      @cell_refs = GappedNumHash.new
      this = self
      cur_index = 0
      @x_row.each_element do |x_cell|
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
      cell = @cell_refs[ind]
      cell && cell.data
    end

    def []= ind, val
      key, cell = @cell_refs.at ind
      return unless key # TODO: not to leave
      if key.atom?
        cell.set_data val
      else
        cells = cell.send :insert_split, ind-key.first, val
        @cell_refs.insert_split ind, cells
        val
      end
    end

    def cellnum
      if ind = @cell_refs.last_index then ind+1 else 0 end
    end

    private

    def remove!
      @x_row.remove!
    end

    # returns self or nil
    def reduce_repeated
      rep = repeated?
      return unless rep && rep > 1

      @x_row.ns_remove_attr 'table:number-rows-repeated'
      if rep > 2
        @x_row.ns_set_attr 'table:number-rows-repeated', rep-1
      end

      self
    end

    def insert_after
      @x_row.next = @x_row.ns_copy_with_attrs

      start_cur_index = 0 # index of first cell with current style
      cur_style = @cell_refs[0].style_name
      refs = @cell_refs.each do |key, cell|
        new_style = cell.style_name
        if cur_style != new_style
          insert_add_cell cur_style, key.first - start_cur_index

          start_cur_index = key.first
          cur_style = new_style
        end
      end
      insert_add_cell cur_style, refs.last[0].last - start_cur_index + 1

      Row.new(@worksheet, @x_row.next)
    end

    def insert_add_cell style, repeated
      opts = {}
      opts[:style_name] = style if style
      opts[:repeated] = repeated if repeated > 1

      @x_row.next << Cell.send(:new_empty_x, @x_row.doc, opts)

      self
    end

  end

end
