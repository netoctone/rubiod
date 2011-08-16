class LibXML::XML::Node
  def borrow_attrs node
    node.each_attr do |a|
      self["#{a.ns.prefix}:#{a.name}"] = a.value
    end
    self
  end

  def copy_with_attrs
    copy = LibXML::XML::Node.new "#{namespaces.namespace.prefix}:#{name}"
    copy.borrow_attrs self
  end
end
