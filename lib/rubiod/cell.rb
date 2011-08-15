class Rubiod::Cell

  def initialize row, x_cell
    @row = row
    @x_cell = x_cell
  end

  attr_reader :row

  def repeated?
    @x_cell['number-columns-repeated']
  end

  def no_data?
    repeated? || @x_cell.children.empty?
  end

  def first_p_content
    @x_cell.first_element_child.content
  end

end
