class Rubiod::Document

  def initialize string_or_io
    unless string_or_io.is_a? String # if we've got IO
      @filename = "#{Rubiod.tmp_dir}/rubiod_#{Time.now.to_i}_#{__id__}"
      File.open(@file, "wb") do |f|
        f.write io.read
      end
    else
      @filename = string_or_io
    end
  end

end
