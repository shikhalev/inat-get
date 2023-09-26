# frozen_string_literal: true

require 'time'
require 'date'
require 'json'

module Types

  refine Sring::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      data.to_s
    end

    def from_db cache, data
      return nil if data.nil?
      data.to_s
    end

    def db_type
      'TEXT'
    end

  end

  refine Symbol::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      data.intern
    end

    def from_db cache, data
      return nil if data.nil?
      data.intern
    end

    def db_type
      'TEXT'
    end

  end

  refine Integer::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      data.to_i
    end

    def from_db cache, data
      return nil if data.nil?
      data.to_i
    end

    def db_type
      'INTEGER'
    end

  end

  refine Float::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      data.to_f
    end

    def from_db cache, data
      return nil if data.nil?
      data.to_f
    end

    def db_type
      'REAL'
    end

  end

  refine Date::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      Date::parse data
    end

    def from_db cache, data
      return nil if data.nil?
      TIme::at(data).to_date
    end

    def db_type
      'INTEGER'
    end

  end

  refine Time::singleton_class do

    def from_api cache, data
      return nil if data.nil?
      Time::parse data
    end

    def from_db cache, data
      return nil if data.nil?
      Time::at data
    end

    def db_type
      'INTEGER'
    end

  end

  refine URI::singleton_class do

    def from_api cache, data
      return nil if data.nil? || data.empty?
      @@escaper ||= URI::Parser::new
      URI(@@escaper.escape(data))
    end

    def from_db cache, data
      return nil if data.nil? || data.empty?
      @@escaper ||= URI::Parser::new
      URI(@@escaper.escape(data))
    end

    def db_type
      'TEXT'
    end

  end

  refine String do

    def to_db
      self
    end

  end

  refine Symbol do

    def to_db
      to_s
    end

  end

  refine Integer do

    def to_db
      self
    end

  end

  refine Float do

    def to_db
      self
    end

  end

  refine Date do

    def to_db
      to_time.to_i
    end

  end

  refine Time do

    def to_db
      to_i
    end

  end

  refine TrueClass do

    def to_db
      1
    end

  end

  refine FalseClass do

    def to_db
      0
    end

  end

  refine Array do

    def to_db
      JSON.stringify(self.map { |i| i.to_db })
    end

  end

  refine URI do

    def to_db
      to_s
    end

  end

end

module Bool

  class << self

    def from_api cache, data
      return nil if data.nil?
      !!data
    end

    def from_db cache, data
      return nil if data.nil?
      data != 0
    end

    def db_type
      'INTEGER'
    end

  end

end

class Items

  class << self

    def [] cls
      return nil if cls.nil?
      @values ||= {}
      @values[cls] ||= new cls
      @values[cls]
    end

    private :new

  end

  attr_reader :item_class

  def initialize cls
    @item_class = cls
  end

  def from_api cache, data
    data.map { |item| @item_class.from_api(item) }
  end

  # TODO: подумать! вообще-то массивов в БД быть не должно
  def from_db cache, data
    if String === data
      data = JSON.parse(data)
    end
    data.map { |item| @item_class.from_db(item) }
  end

end
