# frozen_string_literal: true

require 'time'
require 'date'

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

    def self.ddl
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

end
