class RulesParser
  def initialize(file_name)
    @file_name = file_name
  end

  def get_lines
    IO.readlines(@file_name)
  end

  def line_to_csv(line)

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
