# frozen_string_literal: true

require 'time'
require 'date'
require 'uri'

module Types

  refine String.singleton_class do

    def make data, cache: nil, from: :API
      case data
      when String, Symbol
        data.to_s
      when nil
        nil
      else
        raise TypeError, "Invalid source for String: #{data.inspect}!"
      end
    end

    def db_type
      :TEXT
    end

  end

  refine Symbol.singleton_class do

    def make data, cache: nil, from: :API
      case data
      when String, Symbol
        data.intern
      when nil
        nil
      else
        raise TypeError, "Invalid source for Symbol: #{data.inspect}!"
      end
    end

    def db_type
      :TEXT
    end

  end

  refine Integer.singleton_class do

    def make data, cache: nil, from: :API
      case data
      when Integer, NilClass
        data
      else
        raise TypeError, "Invalid source for Integer: #{data.inspect}!"
      end
    end

    def db_type
      :INTEGER
    end

  end

  refine Float.singleton_class do

    def make data, cache: nil, from: :API
      case data
      when Float, NilClass
        data
      else
        raise TypeError, "Invalid source for Float: #{data.inspect}!"
      end
    end

    def db_type
      :REAL
    end

  end

  refine Date.singleton_class do

    def make data, cache: nil, from: :API
      return nil if data.nil?
      if from == :API && String === data
        Date::parse data
      elsif from == :DB && Integer === data
        Time::at(data).to_date
      else
        raise TypeError, "Invalid source for Date: #{data.inspect}!"
      end
    end

    def db_type
      :INTEGER
    end

  end

  refine Time.singleton_class do

    def make data, cache: nil, from: :API
      return nil if data.nil?
      if from == :API && String === data
        Time::parse data
      elsif from == :DB && Integer === data
        Time::at(data)
      else
        raise TypeError, "Invalid source for Time: #{data.inspect}!"
      end
    end

    def db_type
      :INTEGER
    end

  end

  refine URI.singleton_class do

    def make data, cache: nil, from: :API
      return nil if data.nil?
      raise TypeError, "Invalid source for URI: #{data.inspect}!" unless String === data
      return nil if data.empty?
      URI(data)
    end

    def db_type
      :TEXT
    end

  end

  refine NilClass do

    def to_db
      self
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

  refine URI do

    def to_db
      to_s
    end

  end

end

module Boolean

  class << self

    def make data, cache: nil, from: :API
      return nil if data.nil?
      if from == :API && (data == false || data == true)
        data
      elsif from == :DB && Integer === data
        data != 0
      else
        raise TypeError, "Invalid source for Boolean: #{data.inspect}!"
      end
    end

    def db_type
      :INTEGER
    end

  end

end

class List

  class << self

    def [] cls
      raise TypeError, "Invalid item type for List: #{cls.inspect}" unless cls.respond_to?(:make)
      @@classes[cls] ||= new cls
      @@classes[cls]
    end

    private :new

  end

  attr_reader :item_class

  def initialize cls
    @item_class = cls
  end

  def make data, cache: nil, from: :API
    raise TypeError, "Invalid source for List[#{@item_class}]: #{data.inspect}!" unless Array === data
    data.map { |item| @item_class.make(item, cache: cache, from: from) }
  end

end
