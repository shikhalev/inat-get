# frozen_string_literal: true

module ShiftAge

  class << self

    def parse source
      source = source.to_i if /\d+/ === source
      source = source.to_s.downcase.intern if Symbol === source || String === source
      case source
      when nil
        0
      when Integer
        source
      when :daily, :weekly, :monthly
        source
      else
        raise TypeError, "Invalid shift age value: #{source}!"
      end
    end

  end

end
