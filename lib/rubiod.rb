require 'libxml'
require 'libxml_ruby_extensions'
require 'gapped_num_hash'
require 'zip/zipfilesystem'

module Rubiod
  require 'rubiod/document'
  require 'rubiod/spreadsheet'
  require 'rubiod/worksheet'
  require 'rubiod/row'
  require 'rubiod/cell'

  @tmp_dir = '/tmp'
  class << self
    attr_accessor :tmp_dir
  end
end
