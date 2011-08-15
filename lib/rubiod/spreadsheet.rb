module Rubiod

  class Spreadsheet < Document

    def initialize string_or_io
      super

      @x_content = Zip::ZipFile.open(@filename) do |zip|
        Nokogiri::XML(zip.get_input_stream('content.xml'))
      end

      x_spread = @x_content.xpath('//office:spreadsheet').first
      x_tabs_with_index = x_spread.children.each_with_index
      this = self
      @worksheets = x_tabs_with_index.inject({}) do |wss, (x_tab, i)|
        ws = Worksheet.new(this, x_tab)
        wss[x_tab['name']] = ws
        wss[i] = ws
        wss
      end
    end

    attr_reader :worksheets

    def worksheet_names
      @worksheets.each_key.reject { |k| k.kind_of? Numeric }
    end

    def [] ws_index_or_name, *rest_indexes
      if rest_indexes.empty?
        @worksheets[ws_index_or_name]
      else
        @worksheets[ws_index_or_name][*rest_indexes]
      end
    end

  end

end
