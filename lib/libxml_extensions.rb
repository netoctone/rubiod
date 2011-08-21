class LibXML::XML::Node
  def ns_borrow_attrs node
    node.each_attr do |a|
      LibXML::XML::Attr.ns_new self, a.name, a.value, a.ns
    end
    self
  end

  def ns_copy_with_attrs
    ns_copy.ns_borrow_attrs self
  end

  def ns_copy
    LibXML::XML::Node.new name, nil, namespaces.namespace
  end

  def ns_set_attr name_with_opt_prefix, val
    ns, name = ns_parse_name name_with_opt_prefix
    LibXML::XML::Attr.ns_new self, name, val, ns
    self
  end

  def ns_remove_attr name_with_opt_prefix
    ns, name = ns_parse_name name_with_opt_prefix
    if ns
      attr = attributes.get_attribute_ns ns.href, name
      attr.ns_remove! if attr
    else
      attr = attributes.get_attribute name
      attr.ns_remove! if attr && attr.ns.nil?
    end
  end

  def ns_parse_name name_with_opt_prefix
    ns_and_name = name_with_opt_prefix.split ':'
    ns_and_name.unshift nil if ns_and_name.size == 1
    ns_and_name[0] = namespaces.find_by_prefix ns_and_name[0]
    ns_and_name
  end

  def ns_elements
    elems = []
    each_element { |e| elems << e }
    elems
  end
end

class LibXML::XML::Attr
  def self.ns_new node, name, val, ns_or_prefix=nil
    attr = new node, name, val.to_s
    if ns_or_prefix
      attr.namespaces.namespace = if ns_or_prefix.is_a? String
        node.namespaces.find_by_prefix ns_or_prefix
      else
        ns_or_prefix
      end
    end
    attr
  end

  def ns_remove!
    val = value
    remove!
    val
  end
end

class LibXML::XML::Document
  def ns_create_node name_with_opt_prefix, content=nil, attr_hash=nil
    ns, name = root.ns_parse_name name_with_opt_prefix
    node = LibXML::XML::Node.new name, content && content.to_s, ns

    if attr_hash
      attr_hash.each do |name_with_opt_prefix, val|
        ns, name = root.ns_parse_name name_with_opt_prefix
        LibXML::XML::Attr.ns_new node, name, val, ns
      end
    end

    node
  end
end
