class Rubiod::Row
  def initialize worksheet, x_row
    @worksheet = worksheet
    @x_row = x_row

    @x_cell_refs = GappedNumHash.new
    cur_index = 0
    @x_row.find('//table:table-cell').each do |x_cell|
      if rep = x_cell['number-columns-repeated']
        rep = rep.to_i
        @x_cell_refs.insert cur_index..cur_index+rep-1, x_cell
        cur_index += rep
      else
        @x_cell_refs.insert cur_index, x_cell
        cur_index += 1
      end
    end
  end

  attr_reader :worksheet

  def repeated?
    @x_row['number-rows-repeated']
  end

  def [] ind
    x_cell = @x_cell_refs[ind]
    return nil if x_cell['number-columns-repeated']
    x_cell.find_first('//text:p').content
  end

  def []= ind, val
  end
end
