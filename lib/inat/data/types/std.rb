# frozen_string_literal: true

require "time"
require "date"
require "uri"

module INat::Types; end

module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

# TODO: возможно, разбить по функционалу

module INat::Types::Std
  refine Boolean do
    def to_db
      self && 1 || 0
    end

    def to_query
      inspect
    end
  end

  refine Boolean.singleton_class do
    def parse(src)
      return nil if src == nil
      return src if Boolean === src
      raise TypeError, "Source must be a Boolean!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db(src)
      return nil if src == nil
      return src if Boolean === src
      return src != 0 if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end
  end

  refine Integer do
    def to_db
      self
    end

    def to_query
      to_s
    end
  end

  refine Integer.singleton_class do
    def parse(src)
      return nil if src == nil
      return src if Integer === src
      return src.to_i if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db(src)
      return nil if src == nil
      return src if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end
  end

  refine String do
    def to_db
      self
    end

    def to_query
      self
    end
  end

  refine String.singleton_class do
    def parse(src)
      return nil if src == nil
      return src if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :TEXT
    end

    def from_db(src)
      return nil if src == nil
      return src if String === src
      raise TypeError, "Source must be a String!", caller
    end
  end

  refine Symbol do
    def to_db
      self.to_s
    end

    def to_query
      to_s
    end
  end

  refine Symbol.singleton_class do
    def parse(src)
      return nil if src == nil
      return src if Symbol === src
      return src.intern if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :TEXT
    end

    def from_db(src)
      return nil if src == nil
      return src if Symbol === src
      return src.intern if String === src
      raise TypeError, "Source must be a String!", caller
    end
  end

  refine Float do
    def to_db
      self
    end

    def to_query
      to_s
    end
  end

  refine Float.singleton_class do
    def parse(src)
      return nil if src == nil
      return src if Float === src
      return src.to_f if String === src || Integer === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :REAL
    end

    def from_db(src)
      return nil if src == nil
      return src if Float === src
      raise TypeError, "Source must be a Float!", caller
    end
  end

  refine Time do
    def to_db
      to_i
    end

    def to_query
      xmlschema
    end
  end

  refine Time.singleton_class do
    alias :std_parse :parse

    def parse(src)
      return nil if src == nil
      return src if Time === src
      return std_parse(src) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db(src)
      return nil if src == nil
      return src if Time === src
      return Time::at(src) if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end
  end

  refine Date do
    def to_db
      to_time.to_i
    end

    def to_query
      xmlschema
    end
  end

  refine Date.singleton_class do
    alias :std_parse :parse

    def parse(src)
      return nil if src == nil
      return src if Date === src
      return std_parse(src) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db(src)
      return nil if src == nil
      return src if Date === src
      return Time::at(src).to_date if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end
  end

  refine URI do
    def to_db
      to_s
    end
  end

  refine URI.singleton_class do
    pre_verbose = $VERBOSE
    $VERBOSE = nil

    alias :std_parse :parse

    def parse(src)
      return nil if src == nil
      return src if URI === src
      url = URI::DEFAULT_PARSER.escape(src).gsub("+", "%2B")
      return std_parse(url) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    $VERBOSE = pre_verbose

    def ddl
      :TEXT
    end

    def from_db(src)
      parse src
      # return nil if src == nil
      # return src if URI === src
      # return URI(URI::DEFAULT_PARSER.escape(src)) if String === src
      # raise TypeError, "Source must be a String!", caller
    end
  end

  refine NilClass do
    def self.parse(src)
      nil
    end

    def to_db
      nil
    end
  end

  refine Array do
    def to_query
      map { |i| i.to_query }.join(",")
    end
  end

  refine Module do
    def short_name
      name.split("::").last
    end
  end
end
