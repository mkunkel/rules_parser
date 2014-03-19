class RulesParser
  def initialize(file_in, file_out = 'output.csv')
    @file_in = file_in
    @file_out = file_out
  end

  def write
    write_to_file
  end

  private

  def get_lines
    IO.readlines(@file_in)
  end

  def get_type(number, text)
    if number.length > 0
      "level#{number.split('.').length}"
    elsif text[/^--[\w]*--/]
      "placeholder"
    else
      text.length > 40 ? "paragraph" : "header"
    end
  end

  def line_to_csv(line)
    return false if line.strip.chomp.length == 0
    regex = /^[\d\.]*/
    number = line[regex]
    text = line.gsub(regex, "").strip.chomp
    type = get_type(number, text)
    text = text.gsub(/-/, "") if type == "placeholder"
    "#{number},#{text},#{type}"
  end

  def write_to_file
    output = File.open(@file_out, 'w')
    get_lines.each do |line|
      next_line = line_to_csv(line)
      output.puts next_line if next_line
    end
    output.close
  end
end
