require 'time'
require 'date'

class String

  class << self

    def column_defs
      :TEXT
    end

    def from_column db, src
      case src
      when String
        src
      when Symbol
        src.to_s
      else
        raise TypeError, "#{ src.inspect } is not a string"
      end
    end

    def from_json src
      case src
      when String
        src
      when Symbol
        src.to_s
      else
        raise TypeError, "#{ src.inspect } is not a string"
      end
    end

    private def new_string_class length
      cls = Class.new String do
        define_singleton_method :column_defs do
          "VARCHAR(#{ length })".intern
        end
        define_singleton_method :name do
          "String[#{ length }]"
        end
        define_singleton_method :inspect do
          "String[#{ length }]"
        end
        define_singleton_method :=== do |value|
          String === value && value.length <= length
        end
      end
      cls.const_set :LENGTH, length
      cls
    end

    def [] length
      @@string_classes ||= {}
      @@string_classes[length] ||= new_string_class length
      @@string_classes[length]
    end

  end

  def to_column
    self
  end

  def to_json **opts
    self
  end

end

class Symbol

  class << self

    def column_defs
      'VARCHAR(255)'.intern
    end

    def from_column db, src
      case src
      when String
        src.intern
      when Symbol
        src
      else
        raise TypeError, "#{ src.inspect } is not a symbol"
      end
    end

    def from_json src
      case src
      when String
        src.intern
      when Symbol
        src
      else
        raise TypeError, "#{ src.inspect } is not a symbol"
      end
    end

    private def new_symbol_class length
      cls = Class.new Symbol do
        define_singleton_method :column_defs do
          "VARCHAR(#{ length })".intern
        end
        define_singleton_method :name do
          "Symbol[#{ length }]"
        end
        define_singleton_method :inspect do
          "Symbol[#{ length }]"
        end
        define_singleton_method :=== do |value|
          Symbol === value && value.length <= length
        end
      end
      cls.const_set :LENGTH, length
      cls
    end

    def [] length
      @@symbol_classes ||= {}
      @@symbol_classes[length] ||= new_symbol_class length
      @@symbol_classes[length]
    end

  end

  def to_column
    self.to_s
  end

  def to_json **opts
    self.to_s
  end

end

class Numeric

  class << self

    def from_column db, src
      case src
      when Numeric
        src
      else
        raise TypeError, "#{ src.inspect } is not a number"
      end
    end

    def from_json src
      case src
      when Numeric
        src
      else
        raise TypeError, "#{ src.inspect } is not a number"
      end
    end

    private def new_numeric_class precision, scale
      cls = Class.new Numeric do
        define_singleton_method :column_defs do
          "NUMERIC(#{ precision }, #{ scale })".intern
        end
        define_singleton_method :name do
          "Numeric[#{ precision }, #{ scale }]"
        end
        define_singleton_method :inspect do
          "Numeric[#{ precision }, #{ scale }]"
        end
      end
      cls.const_set :PRECISION, precision
      cls.const_set :SCALE, scale
      cls
    end

    def [] precision, scale = 0
      key = "#{ length }_#{ scale }".intern
      @@numeric_classes ||= {}
      @@numeric_classes[key] ||= new_numeric_class precision, scale
      @@numeric_classes[key]
    end

  end

  def to_column
    self
  end

  def to_json **opts
    self
  end

end

class Integer

  class << self

    def column_defs
      :BIGINT
    end

    def from_column db, src
      case src
      when Integer
        src
      else
        raise TypeError, "#{ src.inspect } is not an integer"
      end
    end

    def from_json src
      case src
      when Integer
        src
      else
        raise TypeError, "#{ src.inspect } is not an integer"
      end
    end

    private def new_integer_class width
      sql = case width
      when 2
        :SMALLINT
      when 4
        :INTEGER
      when 8
        :BIGINT
      else
        raise ArgumentError, "Unsupported width: #{ width }"
      end
      cls = Class.new Integer do
        define_singleton_method :column_defs do
          sql
        end
        define_singleton_method :name do
          "Integer[#{ width }]"
        end
        define_singleton_method :inspect do
          "Integer[#{ width }]"
        end
      end
      cls.const_set :WIDTH, width
      cls
    end

    def [] width
      @@integer_classes ||= {}
      @@integer_classes[width] ||= new_integer_class width
      @@integer_classes[width]
    end

  end

end

Int16 = Integer[2]
Int32 = Integer[4]
Int64 = Integer[8]

class Float

  class << self

    def column_defs
      'DOUBLE PRECISION'.intern
    end

    def from_column db, src
      case src
      when Float
        src
      else
        raise TypeError, "#{ src.inspect } is not a float"
      end
    end

    def from_json src
      case src
      when Float
        src
      else
        raise TypeError, "#{ src.inspect } is not a float"
      end
    end

    private def new_float_class width
      sql = case width
      when 4
        :REAL
      when 8
        'DOUBLE PRECISION'.intern
      else
        raise ArgumentError, "Unsupported width: #{ width }"
      end
      cls = Class.new Float do
        define_singleton_method :column_defs do
          sql
        end
        define_singleton_method :name do
          "Float[#{ width }]"
        end
        define_singleton_method :inspect do
          "Float[#{ width }]"
        end
      end
      cls.const_set :WIDTH, width
      cls
    end

    def [] width
      @@float_classes ||= {}
      @@float_classes[width] ||= new_float_class width
      @@float_classes[width]
    end

  end

end

Real = Float[4]
Double = Float[8]

class Time

  class << self

    def column_defs
      'TIMESTAMP(6) WITH TIME ZONE'.intern
    end

    def from_column db, src
      case src
      when Time, Date, DateTime
        src.to_time
      else
        raise TypeError, "#{ src.inspect } is not a time"
      end
    end

    def from_json src
      case src
      when Time, Date, DateTime
        src.to_time
      when String
        Time.parse(src)
      else
        raise TypeError, "#{ src.inspect } is not a time"
      end
    end

  end

  def to_column
    self
  end

  def to_json **opts
    self.xmlschema(6)
  end

end

class Date

  class << self

    def column_defs
      :DATE
    end

    def from_column db, src
      case src
      when Date, Time, DateTime
        src.to_date
      else
        raise TypeError, "#{ src.inspect } is not a date"
      end
    end

    def from_json src
      case src
      when Date, Time, DateTime
        src.to_date
      when String
        Date.parse(src)
      else
        raise TypeError, "#{ src.inspect } is not a date"
      end
    end

  end

  def to_column
    self
  end

  def to_json **opts
    self.xmlschema
  end

end

class DateTime < Date

  class << self

    def column_defs
      'TIMESTAMP(6) WITH TIME ZONE'.intern
    end

    def from_column db, src
      case src
      when Date, DateTime, Time
        src.to_datetime
      else
        raise TypeError, "#{ src.inspect } is not a datetime"
      end
    end

    def from_json src
      case src
      when Date, DateTime, Time
        src.to_datetime
      when String
        DateTime.parse(src)
      else
        raise TypeError, "#{ src.inspect } is not a datetime"
      end
    end

  end

  def to_json **opts
    self.xmlschema(6)
  end

end

module Boolean

  class << self

    def column_defs
      :BOOLEAN
    end

    def from_column db, src
      case src
      when TrueClass, FalseClass
        src
      else
        raise TypeError, "#{ src.inspect } is not a boolean"
      end
    end

    def from_json src
      case src
      when TrueClass, FalseClass
        src
      when String
        src.casecmp('true').zero?
      else
        raise TypeError, "#{ src.inspect } is not a boolean"
      end
    end

  end

  def to_column
    self
  end

  def to_json **opts
    self
  end

end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end
