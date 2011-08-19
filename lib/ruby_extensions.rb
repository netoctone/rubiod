def Range num_or_range
  num_or_range.is_a?(Range) ? num_or_range : num_or_range..num_or_range
end

class Range
  def atom?
    first == last
  end

  def move int
    exclude_end? ? first+int...last+int : first+int..last+int
  end

  def move! int
    raise 'not implemented yet'
  end
end
