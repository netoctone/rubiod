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
    no_data? ? nil : @x_cell.first_element_child.content
  end

end
