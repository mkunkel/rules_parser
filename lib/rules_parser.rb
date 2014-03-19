class RulesParser
  def initialize(file_name)
    @file_name = file_name
  end

  private

  def get_lines
    IO.readlines(@file_name)
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
    output = File.open(@file_name, 'w')
    @config.each do |key, value|
      output.puts "[#{key}]"
      value.each { |k, v| output.puts "#{k}:#{v}" }
    end
    output.close
  end
end
