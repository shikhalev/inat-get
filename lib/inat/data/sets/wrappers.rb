# frozen_string_literal: true

require 'date'

class Year

  class << self

    private :new

    def [] source
      return nil if source == nil
      return source if Year === source
      year = case source
      when Date, Time
        source.year
      when String
        date = Date::parse source
        date.year
      when Integer
        source
      else
        raise TypeError, "Invalid year key: #{ source.inspect }!", caller
      end
      @years ||= {}
      @years[year] ||= new year
      @years[year]
    end

  end

  attr_reader :year

  def initialize year
    @year = year
  end

  include Comparable

  def <=> other
    return nil unless Year === other
    @year <=> other.year
  end

  def - num
    self.class[@year - num]
  end

  def to_s
    "<i class=\"glyphicon glyphicon-calendar\"></i>  #{ @year }"
  end

end

class Month

  class << self

    private :new

    def [] source
      return nil if source == nil
      return source if Month === source
      month = case source
      when Date, Time
        source.month
      when String
        date = Date::parse source
        date.month
      when Integer
        source
      else
        raise TypeError, "Invalid month key: #{ source.inspect }!", caller
      end
      @months ||= {}
      @months[month] ||= new month
      @months[month]
    end

  end

  attr_reader :month

  def initialize month
    @month = month
  end

  include Comparable

  def <=> other
    return nil unless Month === other
    @month <=> other.month
  end

end

class Day

  class << self

    attr_reader :day

    def [] source
      return nil if source == nil
      return source if Day === source
      day = case source
      when Date, Time
        source.day
      when String
        date = Date::parse source
        date.day
      when Integer
        source
      else
        raise TypeError, "Invalid day key: #{ source.inspect }!", caller
      end
      @days ||= {}
      @days[day] ||= new day
      @days[day]
    end

  end

  attr_reader :day

  def initialize day
    @day = day
  end

  include Comparable

  def <=> other
    return nil unless Day === other
    @day <=> other.day
  end

end
