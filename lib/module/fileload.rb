module FileLoad
  def self.file_lines_to_array(filename)
    array = []
    lines = File.open(filename)
    lines.each do |line|
      array << line.chomp
    end
    array
  end
end