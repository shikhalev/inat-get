require "date"
require "time"

module Md

  def self.included mod
    mod.extend Md::Ext
  end

  def from! hash
    hash.each do |key, value|
      self.send "#{key}=", value
    end
    self
  end

  def each_field
    self.singleton_class.fields.each do |field|
      value = self.send field
      yield field, value if !value.nil?
    end
  end

end

module Md::Types

  refine String.singleton_class do

    def from value
      value&.to_s
    end

  end

  refine Date.singleton_class do

    def from value
      if value.nil?
        nil
      else
        Date.parse value
      end
    end

  end

  refine Time.singleton_class do

    def from value
      if value.nil?
        nil
      else
        Time.parse value
      end
    end

  end

  refine Integer.singleton_class do

    def from value
      value&.to_i
    end

  end

  refine Float.singleton_class do

    def from value
      value&.to_f
    end

  end

  refine Symbol.singleton_class do

    def from value
      value&.intern
    end

  end

  refine Array do

    def x_merge! other
      # TODO: check conflict
      if self.size < other.size
        (self.size .. other.size - 1).each do |i|
          self << other[i]
        end
      end
      self
    end

  end

  refine Hash do

    def x_merge! other
      self.merge! other
      self
    end

  end

  refine String do

    def x_merge! other
      # TODO: check conflict
      if self.empty? && !other.empty?
        self.replace other
      end
      self
    end

  end

  module Bool

    class << self

      def from value
        if value.nil?
          nil
        else
          !!value
        end
      end

    end

  end

  class List

    using Md::Types

    class << self

      def [] cls
        @items ||= {}
        @items[cls] ||= new(cls)
        @items[cls]
      end

      private :new
    end

    def initialize cls
      @cls = cls
    end

    def from value
      value.map { |x| @cls.from(x) }
    end

  end

end

module Md::Ext

  using Md::Types

  def field name, **params
    # pp name
    # pp params
    nm = name.intern
    @fields ||= {}
    @fields[nm] = params
    if params[:calculate]
      calculate = params[:calculate]
      define_method nm do
        calculate.call self
      end
    else
      define_method nm do
        instance_variable_get "@#{nm}"
      end
      if !params[:readonly]
        type = params[:type]
        parse = params[:parse]
        check = params[:check]
        define_method "#{nm}=" do |value|
          if parse
            v = parse.call value
          elsif type
            v = type.from value
          else
            v = value
          end
          check.call self, v if check
          prev = instance_variable_get "@#{nm}"
          if prev && prev != v
            if prev.respond_to? :x_merge!
              prev.x_merge! v
              v = prev
            else
              $stderr.puts "Conflict!!!"
              if self.respond_to? :id
                $stderr.puts "#{self.class}: id = #{self.id}"
              end
              $stderr.puts "key = #{nm}"
              $stderr.puts "old value = #{prev.inspect}"
              $stderr.puts "new value = #{v.inspect}"
            end
          end
          instance_variable_set "@#{nm}", v
        end
      end
    end
  end

  def fields
    @fields ||= {}
    result = {}
    ancestors.each do |ancestor|
      result.merge! ancestors.fields if ancestors.respond_to?(:fields)
    end
    result.merge! @fields
    result
  end

  def from hash
    obj = self.new
    obj.send :from!, hash
    obj
  end

end
