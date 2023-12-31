# frozen_string_literal: true

require 'extra/enum'
require 'extra/uuid'

class Enum

  class << self

    pre_verbose = $VERBOSE
    $VERBOSE = nil

    alias :old_parse :parse

    def parse src
      return nil if src == nil
      return src if self === src
      case src
      when Integer, Symbol
        self[src]
      when String
        self.old_parse src, case_sensitive: false
      end
    end

    $VERBOSE = pre_verbose

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
      name = src[:name]&.intern
      return nil if name == nil
      self[name]
    end

  end

  def to_db
    if self.class.any? { |v| Integer === v.data }
      {
        name: name.to_s,
        data: data
      }
    else
      name.to_s
    end
  end

  def to_query
    to_s
  end

end

class UUID

  class << self

    def ddl
      :TEXT
    end

    def from_db src
      parse src
    end

  end

  def to_db
    to_s
  end

  def to_query
    to_s
  end

end
