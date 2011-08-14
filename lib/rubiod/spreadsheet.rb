module Rubiod

  class Spreadsheet < Document

    def initialize string_or_io
      super

      @x_content = Zip::ZipFile.open(@filename) do |zip|
        LibXML::XML::Document.io zip.get_input_stream('content.xml')
      end

      x_spread = @x_content.find_first "//office:spreadsheet"
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

    def [] index_or_name
      @worksheets[index_or_name]
    end

  end

end
