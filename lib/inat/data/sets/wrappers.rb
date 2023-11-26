# frozen_string_literal: true

require 'date'

class Calendarian

  class << self

    private :new

    def [] src
      return nil if src == nil
      return src if self === src
      value = case src
      when Date
        self.date_to_value src
      when Time
        self.date_to_value src.to_date
      when String
        date = Date::parse src
        self.date_to_value date
      when Integer
        src
      else
        raise TypeError, "Invalid date: #{ src.inspect }", caller
      end
      return nil if value == nil
      @values ||= {}
      @values[value] ||= new value
      @values[value]
    end

  end

  attr_reader :value

  def initialize value
    @value = value
  end

  include Comparable

  def <=> other
    return nil unless self.class === other
    @value <=> other.value
  end

end

class Year < Calendarian

  class << self

    protected def date_to_value date
      date.year
    end

  end

  alias :year :value

  def - num
    self.class[@value - num]
  end

  def to_s
    "<i class=\"glyphicon glyphicon-calendar\"></i>  #{ @value } год"
  end

  def query_params
    "year=#{ @value }"
  end

end

class Month < Calendarian

  class << self

    protected def date_to_value date
      date.month
    end

  end

  alias :month :value

  NAMES = {
    1  => 'Январь',
    2  => 'Февраль',
    3  => 'Март',
    4  => 'Апрель',
    5  => 'Май',
    6  => 'Июнь',
    7  => 'Июль',
    8  => 'Август',
    9  => 'Сентябрь',
    10 => 'Октябрь',
    11 => 'Ноябрь',
    12 => 'Декабрь'
  }

  def to_s
    "<i class=\"glyphicon glyphicon-calendar\"></i>  #{ NAMES[@value] }"
  end

  def query_params
    "month=#{ @value }"
  end

end

class Day < Calendarian

  class << self

    protected def date_to_value date
      date.day
    end

  end

  alias :day :value

  def to_s
    "<i class=\"glyphicon glyphicon-calendar\"></i>  #{ @value }"
  end

  def query_params
    "day=#{ @value }"
  end

end

class Winter < Calendarian

  class << self

    protected def date_to_value date
      month = date.month
      if month <= 4
        date.year
      elsif month >= 10
        date.year + 1
      else
        nil
      end
    end

  end

  alias :winter :value

  def to_s
    "<i class=\"glyphicon glyphicon-calendar\"></i>  Зима #{ @value - 1 }–#{ @value }"
  end

  def query_params
    "d1=#{ @value - 1 }-10-01&d2=#{ @value }-04-30"
  end

end
