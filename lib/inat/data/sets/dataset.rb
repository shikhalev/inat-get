# frozen_string_literal: true

require_relative 'listers'
require_relative 'list'

class DataSet

  attr_reader :time
  attr_reader :object
  attr_reader :observations

  def initialize object, observations, time: Time::new
    @object = object
    @time = time
    @observations = observations.sort_by { |o| o.sort_key }.uniq
    @sorted = true
    @by_id = {}
    @observations.each do |o|
      @by_id[o.id] = o
    end
  end

  def self.zero
    new nil, []
  end

  include Enumerable

  def each
    if block_given?
      @observations.sort_by! { |o| o.sort_key } unless @sorted
      @sorted = true
      @observations.each do |o|
        yield o
      end
    else
      to_enum :each
    end
  end

  def reverse_each
    if block_given?
      @observations.sort_by! { |o| o.sort_key } unless @sorted
      @sorted = true
      @observations.reverse_each do |o|
        yield o
      end
    else
      to_enum :reverse_each
    end
  end

  def count
    @observations.size
  end

  def to_list lister = Listers::SPECIES, sorter: nil
    List::new self, lister, sorter: sorter, time: @time
  end

  def include? observation
    @by_id.has_key? observation.id
  end

  def empty?
    @observations.empty?
  end

  def where &block
    raise ArgumentError, "Block must be provided!", caller unless block_given?
    DataSet::new nil, @observations.select(&block), time: @time
  end

  alias :=== :include?

  def << observation
    raise TypeError, "Argument must be an Observation (#{ observation.inspect })!" unless Observation === observation
    if !self.include?(observation)
      @observations << observation
      @by_id[observation.id] = observation
      @sorted = false
    end
  end

  def | other
    obj = @object == other.object ? @object : nil
    DataSet::new obj, @observations + other.observations, time: Time::new
  end

  def & other
    obj = @object == other.object ? @object : nil
    DataSet::new obj, @observations.select { |o| other.include?(o) }, time: Time::new
  end

  def - other
    obj = @object == other.object ? @object : nil
    DataSet::new obj, @observations.select { |o| !other.include?(o) }, time: Time::new
  end

  def to_a
    @observations.dup
  end

end
