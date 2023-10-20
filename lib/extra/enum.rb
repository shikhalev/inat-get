# frozen_string_literal: true

class Enum

  class << self

    def inherited sub
      if self != ::Enum
        raise TypeError, "Enum classes are closed!", caller
      end
    end

    private :new

    private def item name, order = nil, description: nil, data: nil
      raise TypeError, "Name of enum value must be a Symbol!", caller unless Symbol === name
      raise TypeError, "Order of enum value must be a Integer!", caller unless nil === order || Integer === order
      raise TypeError, "Description of enum value must be a String!", caller unless nil === description || String === description
      @values ||= []
      @by_name ||= {}
      @by_order ||= {}
      order ||= (@values.map(&:order).max || 0) + 1
      value = new name, order, description, data
      value.freeze
      @values << value
      @by_name[name] = value
      @by_order[order] = value
      self.const_set name, value
      return value
    end

    private def items *names, **names_with_order
      names.each do |name|
        item name
      end
      names_with_order.each do |name, order|
        item name, order
      end
      return values
    end

    private def item_alias **params
      @aliases ||= {}
      params.each do |name, value|
        raise TypeError, "Alias name must be a Symbol!", caller unless Symbol === name
        value = self[value] if Symbol === value
        raise TypeError, "Alias value must be a Symbol or #{ self.name }!", caller unless self === value
        @aliases[name] = value
        @by_name[name] = value
        self.const_set name, value
      end
      return aliases
    end

    def values
      @values ||= []
      @values.sort_by(&:order).dup.freeze
    end

    def aliases
      @aliases ||= {}
      @aliases.dup.freeze
    end

    def to_a
      values
    end

    def to_h
      @by_name.dup.freeze
    end

    include Enumerable

    def each
      if block_given?
        @values.sort_by(&:order).each do |item|
          yield item
        end
      else
        to_enum :each
      end
    end

    private def get name_or_order
      return nil if name == nil
      result = @by_name[name_or_order] || @by_order[name_or_order]
      raise ArgumentError, "Invalid name or order: #{ name_or_order.inspect }!", caller if result == nil
      return result
    end

    def [] name_or_order
      case name_or_order
      when Symbol, Integer
        @by_name[name_or_order] || @by_order[name_or_order]
      when Range
        Range::new get(name_or_order.begin), get(name_or_order.end), name_or_order.exclude_end?
      else
        raise TypeError, "Invalid key: #{ name_or_order.inspect }!", caller
      end
    end

    def parse src, case_sensitive: true
      raise TypeError, "Source must be a String!", caller unless String === src
      src = src.strip
      prefix = self.name + '::'
      src = src[prefix.length ..] if src.start_with?(prefix)
      return nil if src.empty?
      key = if case_sensitive
        @by_name.keys.find { |v| v.to_s == src }
      else
        src = src.downcase
        @by_name.keys.find { |v| v.to_s.downcase == src }
      end
      raise NameError, "Invalid name: #{ src.inspect }!", caller if key.nil?
      @by_name[key]
    end

  end

  attr_reader :name, :order, :description, :data

  def initialize name, order, description, data
    @name = name
    @order = order
    @description = description
    @data = data
  end

  def intern
    @name
  end

  def to_s
    @name.to_s
  end

  def to_i
    @order
  end

  def inspect
    "#{ self.class.name }::#{ @name }"
  end

  include Comparable

  def <=> other
    @order <=> other.order
  end

  def succ
    self.class.values.select { |v| v.order > @order }.first
  end

  def pred
    self.class.values.select { |v| v.order < @order }.last
  end

end
