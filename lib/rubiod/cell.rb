module Rubiod

  class Cell

    def initialize row, x_cell
      @row = row
      @x_cell = x_cell
    end

    attr_reader :row

    def repeated?
      rep = @x_cell['number-columns-repeated']
      rep && rep.to_i
    end

    def no_data?
      repeated? || @x_cell.children.empty?
    end

    def data
      no_data? ? nil : @x_cell.first.content
    end

    # removes all current attributes and content, so be careful
    def set_data data
      @x_cell.each_attr &:remove!
      @x_cell.each &:remove!
      @x_cell.ns_set_attr 'office:value-type', 'string'
      @x_cell << @x_cell.doc.ns_create_node('text:p', data)
      data
    end

    private

    # cell must be 'repeated?'
    def insert_split left_repeated, data
      if left = create_empty_x(left_repeated)
        @x_cell.prev = left
      end

      if right = create_empty_x(repeated? - left_repeated - 1)
        @x_cell.next = right
      end

      set_data data # mutator

      {
        :left => Cell.new(@row, left),
        :mid => self,
        :right => Cell.new(@row, right)
      }
    end

    def create_empty_x count
      if count > 0
        if count > 1
          create_repeated_x count
        else
          create_single_x
        end
      end
    end

    def create_repeated_x count
      @x_cell.doc.ns_create_node 'table:table-cell', nil, {
        'table:number-columns-repeated' => count
      }
    end

    def create_single_x
      @x_cell.doc.ns_create_node 'table:table-cell'
    end

  end

end
