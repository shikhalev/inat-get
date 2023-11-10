# frozen_string_literal: true

class Compare

  def initialize name, inner_list, outer_lists
    @name = name
    @inner = inner_list
    @outer = outer_lists
  end

  private def generate
    result = []
    # NEED: implement
    result
  end

  def write file = nil
    @output ||= generate
    case file
    when nil
      File.write "#{ @name } - Compare.htm", @output.join("\n")
    when String
      File.write file, @output.join("\n")
    when IO
      file.writet @output.join("\n")
    end
  end

end
