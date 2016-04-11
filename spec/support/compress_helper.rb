module CompressHelper
  def strip_indent(string)
    lines       = string.lines
    match       = /\A( *)/.match(lines.first)
    return string unless match
    whitespaces = match[1].to_s.length
    lines.map { |line| line[whitespaces..-1] }.join
  end
end # CompressHelper
