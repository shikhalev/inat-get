# frozen_string_literal: true

require 'time'
require 'date'

class Period

  attr_reader :value

  def initialize value
    @value = value
  end

  class << self

    private :new

    def parse src
      return nil if src == nil
      raise TypeError, "Source must be a String!", caller unless String === src
      src = src.strip
      value = 0
      case src
      when /^\d+$/
        value = src.to_i
      when /^(\d+[wW])?(\d+[dD])?(\d+[hH])?(\d+[mM])?(\d+[sS])?$/
        weeks = /(\d+)[wW]/.match(src)
        value += weeks[1].to_i * 7 * 24 * 60 * 60 if weeks
        days = /(\d+)[dD]/.match(src)
        value += days[1].to_i * 24 * 60 * 60 if days
        hours = /(\d+)[hH]/.match(src)
        value += hours[1].to_i * 60 * 60 if hours
        minutes = /(\d+)[mM]/.match(src)
        value += minutes[1].to_i * 60 if minutes
        seconds = /(\d+)[sS]/.match(src)
        value += seconds[1].to_i if seconds
      else
        raise ArgumentError, "Invalid source: #{ src }!", caller
      end
      new(value).freeze
    end

    def make weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0
      raise TypeError, "Parameter 'weeks' must be an Integer!", caller   unless Integer === weeks
      raise TypeError, "Parameter 'days' must be an Integer!", caller    unless Integer === days
      raise TypeError, "Parameter 'hours' must be an Integer!", caller   unless Integer === hours
      raise TypeError, "Parameter 'minutes' must be an Integer!", caller unless Integer === minutes
      raise TypeError, "Parameter 'seconds' must be an Integer!", caller unless Integer === seconds
      value =  seconds
      value += minutes             * 60
      value += hours          * 60 * 60
      value += days      * 24 * 60 * 60
      value += weeks * 7 * 24 * 60 * 60
      new(value).freeze
    end

    def diff first, second
      first = first.to_time if Date === first
      second = second.to_time if Date === second
      raise TypeError, "Parameter 'first' must be a Time or Date!", caller  unless Time === first
      raise TypeError, "Parameter 'second' must be a Time or Date!", caller unless Time === second
      value = first.to_i - second.to_i
      new(value).freeze
    end

  end

  WEEK   = make weeks:   1
  DAY    = make days:    1
  HOUR   = make hours:   1
  MINUTE = make minutes: 1
  SECOND = make seconds: 1
  NULL   = make seconds: 0

  def weeks
    g = sgn
    w = @value.abs / (7 * 24 * 60 * 60)
    g * w
  end

  def days all: true
    g = sgn
    d = @value.abs / (24 * 60 * 60)
    all && g * d || g * (d % 7)
  end

  def hours all: false
    g = sgn
    h = @value.abs / (60 * 60)
    all && g * h || g * (h % 24)
  end

  def minutes all: false
    g = sgn
    m = @value.abs / 60
    all && g * m || g * (m % 60)
  end

  def seconds all: false
    g = sgn
    s = @value.abs
    all && g * s || g * (s % 60)
  end

  def sgn
    if @value == 0
      0
    elsif @value > 0
      1
    else
      -1
    end
  end

  def abs
    self.class.make seconds: @value.abs
  end

  def to_i
    @value
  end

  def to_s with_weeks: true
    return '0' if @value == 0
    return "-#{abs.to_s}" if @value < 0
    w = with_weeks && weeks || 0
    d = days all: !with_weeks
    h = hours
    m = minutes
    s = seconds
    result = ''
    result += "#{ w }w" if w != 0
    result += "#{ d }d" if d != 0
    result += "#{ h }h" if h != 0
    result += "#{ m }m" if m != 0
    result += "#{ s }s" if s != 0
    result
  end

  def inspect
    "\#<Period: #{to_s}>"
  end

  include Comparable

  def <=> other
    @value <=> other.value
  end

  def +@
    self
  end

  def -@
    self.class.make(seconds: -@value)
  end

  def + other
    raise TypeError, "Second argument must be a Period!", caller unless Period === other
    self.class.make(seconds: @value + other.value)
  end

  def - other
    raise TypeError, "Second argument must be a Period!", caller unless Period === other
    self.class.make(seconds: @value - other.value)
  end

  def * num
    raise TypeError, "Second argument must be a number!", caller unless Numeric === num
    self.class.make(seconds: (@value * num).to_i)
  end

  def / num
    raise TypeError, "Second argument must be a number!", caller unless Numeric === num
    self.class.make(seconds: (@value / num).to_i)
  end

  class Num

    attr_reader :value

    def initialize num
      @value = num
    end

    def * period
      period * @value
    end

  end

  def coerce num
    case num
    when Integer, Float, Rational
      [ Period::Num::new(num), self ]
    else
      raise TypeError, "Cannot coerce Period to a #{ num.class }!", caller
    end
  end

end

class Time

  alias :preperiod_plus :+
  alias :preperiod_minus :-

  def + arg
    return self + arg.value if Period === arg
    preperiod_plus arg
  end

  def - arg
    return self + (-arg.value) if Period === arg
    preperiod_minus arg
  end

end

class Numeric

  def weeks
    Period::make(weeks: 1) * self
  end

  def days
    Period::make(days: 1) * self
  end

  def hours
    Period::make(hours: 1) * self
  end

  def minutes
    Period::make(minutes: 1) * self
  end

  def seconds
    Period::make(seconds: 1) * self
  end

end
