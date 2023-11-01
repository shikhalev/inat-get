# frozen_string_literal: true

require 'time'
require 'date'
require 'uri'

class Integer

  def self.parse src
    return nil if src == nil
    return src if Integer === src
    return src.to_i if String === src
    raise TypeError, "Source must be a String!", caller
  end

  def self.ddl
    :INTEGER
  end

  def self.from_db src
    return nil if src == nil
    return src if Integer === src
    raise TypeError, "Source must be an Integer!", caller
  end

  def to_db
    self
  end

  def to_query
    to_s
  end

end

class String

  def self.parse src
    return nil if src == nil
    return src if String === src
    raise TypeError, "Source must be a String!", caller
  end

  def self.ddl
    :TEXT
  end

  def self.from_db src
    return nil if src == nil
    return src if String === src
    raise TypeError, "Source must be a String!", caller
  end

  def to_db
    self
  end

  def to_query
    self
  end

end

class Symbol

  def self.parse src
    return nil if src == nil
    return src if Symbol === src
    return src.intern if String === src
    raise TypeError, "Source must be a String!", caller
  end

  def self.ddl
    :TEXT
  end

  def self.from_db src
    return nil if src == nil
    return src if Symbol === src
    return src.intern if String === src
    raise TypeError, "Source must be a String!", caller
  end

  def to_db
    self.to_s
  end

  def to_query
    to_s
  end

end

class Float

  def self.parse src
    return nil if src == nil
    return src if Float === src
    return src.to_f if String === src || Integer === src
    raise TypeError, "Source must be a String!", caller
  end

  def self.ddl
    :REAL
  end

  def self.from_db src
    return nil if src == nil
    return src if Float === src
    raise TypeError, "Source must be a Float!", caller
  end

  def to_db
    self
  end

  def to_query
    to_s
  end

end

class Time

  class << self

    alias :std_parse :parse

    def parse src
      return nil if src == nil
      return src if Time === src
      return std_parse(src) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db src
      return nil if src == nil
      return src if Time === src
      return Time::at(src) if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end

  end

  def to_db
    to_i
  end

  def to_query
    xmlschema
  end

end

class Date

  class << self

    alias :std_parse :parse

    def parse src
      return nil if src == nil
      return src if Date === src
      return std_parse(src) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db src
      return nil if src == nil
      return src if Date === src
      return Time::at(src).to_date if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end

  end

  def to_db
    to_time.to_i
  end

  def to_query
    xmlschema
  end

end

module Boolean

  class << self

    def parse src
      return nil if src == nil
      return src if Boolean === src
      raise TypeError, "Source must be a Boolean!", caller
    end

    def ddl
      :INTEGER
    end

    def from_db src
      return nil if src == nil
      return src if Boolean === src
      return src != 0 if Integer === src
      raise TypeError, "Source must be an Integer!", caller
    end

  end

  def to_db
    self && 1 || 0
  end

  def to_query
    inspect
  end

end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

module URI

  class << self

    pre_verbose = $VERBOSE
    $VERBOSE = nil

    alias :std_parse :parse

    def parse src
      return nil if src == nil
      return src if URI === src
      url = URI::DEFAULT_PARSER.escape(src).gsub('+', '%2B')
      return std_parse(url) if String === src
      raise TypeError, "Source must be a String!", caller
    end

    $VERBOSE = pre_verbose

    def ddl
      :TEXT
    end

    def from_db src
      parse src
      # return nil if src == nil
      # return src if URI === src
      # return URI(URI::DEFAULT_PARSER.escape(src)) if String === src
      # raise TypeError, "Source must be a String!", caller
    end

  end

  def to_db
    to_s
  end

end

class NilClass

  def to_db
    nil
  end

end

class Array

  def to_query
    map { |i| i.to_query }.join(',')
  end

end
