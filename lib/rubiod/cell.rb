class Rubiod::Cell

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
  def insert_split left_rep, data
    right_rep = repeated? - left_rep - 1

    left = if left_rep > 0
      @x_cell.prev = if left_rep > 1 then repeat_x left_rep else empty_x end
    end

    set_data data

    right = if right_rep > 0
      @x_cell.next = if right_rep > 1 then repeat_x right_rep else empty_x end
    end

    {
      :left => Rubiod::Cell.new(@row, left),
      :mid => self,
      :right => Rubiod::Cell.new(@row, right)
    }
  end

  private

  def repeat_x num
    @x_cell.doc.ns_create_node 'table:table-cell', nil, {
      'table:number-columns-repeated' => num
    }
  end

  def empty_x
    @x_cell.doc.ns_create_node 'table:table-cell'
  end

end
