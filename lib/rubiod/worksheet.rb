module Rubiod

  class Worksheet

    def initialize spreadsheet, x_table
      @spreadsheet = spreadsheet
      @x_table = x_table

      @row_refs = GappedNumHash.new
      this = self
      cur_index = 0
      @x_table.ns_elements.select{ |n| n.name == 'table-row' }.each do |x_row|
        row = Row.new(this, x_row)
        if rep = row.repeated?
          @row_refs.insert cur_index..cur_index+rep-1, row
          cur_index += rep
        else
          @row_refs.insert cur_index, row
          cur_index += 1
        end
      end
    end

    attr_reader :spreadsheet

    def [] row, col=nil
      col.nil? ? @row_refs[row] : @row_refs[row][col]
    end

    def []= row, col, val
      rw = @row_refs[row]
      return if rw.nil? || rw.repeated? # not to leave (repeated)
      rw[col] = val
    end

    # inserts a row after specified, copying last's formatting
    # return new row or nil
    def insert row_ind
      row = @row_refs[row_ind]
      return if row.nil? || row.repeated?
      @row_refs.insert_after(row_ind, row.send(:insert_after))[1]
    end

    # deletes specified row
    # returns self or nil
    def delete row_ind
      key, row = @row_refs.at row_ind
      return unless key

      if key.atom?
        if @row_refs.delete row_ind
          row.send :remove!
          self
        end
      else
        if row.send :reduce_repeated
          @row_refs.taper row_ind
          self
        end
      end
    end

  end

end
