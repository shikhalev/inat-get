# frozen_string_literal: true

require 'extra/enum'

class Enum

  class << self

    def parse src
      return nil if src == nil
      return src if self === src
      case src
      when Integer, Symbol
        self[src]
      when String
        self[src.intern]
      end
    end

    def ddl
      if any? { |v| Integer === v.data }
        {
          name: :TEXT,
          data: :INTEGER
        }
      else
        :TEXT
      end
    end

    def from_db src
      return nil if src == nil
      return self[src.intern] if String === src || Symbol === src
      name = src[:name].intern
      self[name]
    end

  end

  def to_db
    if self.class.any? { |v| Integer === v.data }
      {
        name: name,
        data: data
      }
    else
      name
    end
  end

end
