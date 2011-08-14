module Rubiod

  class Worksheet

    def initialize spreadsheet, x_table
      @spreadsheet = spreadsheet
      @x_table = x_table

      @row_refs = GappedNumHash.new
      this = self
      cur_index = 0
      @x_table.children.select{ |n| n.name == 'table-row' }.each do |x_row|
        if rep = x_row['number-rows-repeated']
          rep = rep.to_i
          @row_refs.insert cur_index..cur_index+rep-1, Row.new(this, x_row)
          cur_index += rep
        else
          @row_refs.insert cur_index, Row.new(this, x_row)
          cur_index += 1
        end
      end
    end

    attr_reader :spreadsheet

    def [] row, col
      row = @row_refs[row]
      return nil if row.repeated?
      row[col]
    end

    def []= row, col, val
    end

    def insert row_ind
    end

  end

end
