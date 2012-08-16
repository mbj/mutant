module CompressHelper
  def strip_indent(string)
    lines = string.lines
    match = /\A( *)/.match(lines.first)
    whitespaces = match[1].to_s.length
    stripped = lines.map do |line|
      line[whitespaces..-1]
    end.join
  end
end
