# frozen_string_literal: true

module Values

  def parse_interval value
    case value
    when Integer
      value
    when Time
      value.to_i
    when String
      # TODO: check
      i = 0
      w = /(\d+)[wW]/.match(value)
      i += w[1].to_i * 7 * 24 * 60 * 60 if w
      d = /(\d+)[dD]/.match(value)
      i += d[1].to_i * 24 * 60 * 60 if d
      h = /(\d+)[hH]/.match(value)
      i += h[1].to_i * 60 * 60 if h
      m = /(\d+)[mM]/.match(value)
      i += m[1].to_i * 60 if m
      s = /(\d+)[sS]/.match(value)
      i += s[1].to_i if s
      i
    else
      # TODO: Error
    end
  end

  module_function :parse_interval

end
