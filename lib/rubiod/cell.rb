module Rubiod

  class Cell

    class << self

      private

      # options [Hash] -
      #   :repeated => [Integer] # specify to create repeated cell
      #   :style_name => [String] # specify to set style
      def new_empty_x doc, options={}
        if options.empty?
          doc.ns_create_node 'table:table-cell'
        else
          attr_hash = {}
          if style = options[:style_name]
            attr_hash['table:style-name'] = style
          end
          if num = options[:repeated]
            attr_hash['table:number-columns-repeated'] = num
          end
          doc.ns_create_node 'table:table-cell', nil, attr_hash
        end
      end

    end

    def initialize row, x_cell
      @row = row
      @x_cell = x_cell
    end

    attr_reader :row

    def repeated?
      rep = @x_cell['number-columns-repeated']
      rep && rep.to_i
    end

    def style_name
      @x_cell['style-name']
    end

    def no_data?
      repeated? || @x_cell.children.empty?
    end

    def data
      no_data? ? nil : @x_cell.first.content
    end

    # TODO: maybe, remove only value-type and value
    # removes all current attributes (except style-name) and content
    def set_data data
      @x_cell.each_attr do |a|
        a.remove! unless a.name == 'style-name'
      end
      @x_cell.each &:remove!
      @x_cell.ns_set_attr 'office:value-type', 'string'
      @x_cell << @x_cell.doc.ns_create_node('text:p', data)
      data
    end

    private

    # cell must be 'repeated?'
    def insert_split left_repeated, data
      if left = try_create_empty_x(left_repeated)
        @x_cell.prev = left
      end

      if right = try_create_empty_x(repeated? - left_repeated - 1)
        @x_cell.next = right
      end

      set_data data # mutator

      {
        :left => self.class.new(@row, left),
        :mid => self,
        :right => self.class.new(@row, right)
      }
    end

    def try_create_empty_x count
      if count > 0
        opts = {}
        opts[:style_name] = style_name if style_name
        opts[:repeated] = count if count > 1
        self.class.send :new_empty_x, @x_cell.doc, opts
      end
    end

  end

end
