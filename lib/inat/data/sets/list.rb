# frozen_string_literal: true

autoload :DataSet, 'inat/data/sets/dataset'

class List

  attr_reader :lister, :sorter

  DEFAULT_SORTER = lambda { |ds| ds.object.respond_to?(:sort_key) ? ds.object.sort_key : ds.object }

  def initialize source, lister, sorter: nil, time: Time::new
    @lister = lister
    @sorter = sorter || DEFAULT_SORTER
    @time = time
    @data = {}
    source.each do |observation|
      key = @lister.call observation
      if key != nil
        @data[key] ||= DataSet::new key, [], time: @time
        @data[key] << observation
      end
    end
  end

  def self.zero lister = Listers::SPECIES
    new [], lister
  end

  include Enumerable

  def [] key
    @data[key]
  end

  def each
    if block_given?
      @data.values.sort_by { |ds| @sorter.call(ds) }.each do |ds|
        yield ds
      end
    else
      to_enum :each
    end
  end

  def to_dataset
    observations = []
    @data.values.each do |ds|
      observations += ds.observations
    end
    DataSet::new nil, observations, time: @time
  end

  def include? key
    @data.has_key? key
  end

  def empty?
    @data.empty?
  end

  def count
    @data.size
  end

  def observation_count
    @data.values.map { |ds| ds.count }.sum
  end

  def where &block
    raise ArgumentError, "Block must be provided!", caller unless block_given?
    result = List::new [], @lister, sorter: @sorter, time: @time
    self.each do |ds|
      result << ds if yield(ds)
    end
    result
  end

  def << some
    case some
    when Observation
      key = @lister.call some
      if key != nil
        @data[key] ||= DataSet::new key, [], time: @time
        @data[key] << some
      end
    when DataSet
      if !some.empty?
        valid = some.object != nil && some.all? { |o| @lister.call(o) == some.object }
        if valid
          if @data[some.object]
            @data[some.object] = @data[some.object] | some
          else
            @data[some.object] = some
          end
        else
          some.each do |o|
            self << o
          end
        end
      end
    when Array
      some.each do |o|
        self << o
      end
    else
      raise TypeError, "Can not add this object: #{ some.inspect }!", caller
    end
  end

  alias :=== :include?

  def cover? other
    other.any? { |ds| self.include?(ds.object) }
  end

  include Comparable

  def <=> other
    return nil unless List === other
    if self.cover?(other)
      if other.cover?(self)
        return 0
      else
        return 1
      end
    else
      if other.cover?(self)
        return -1
      else
        return nil
      end
    end
  end

  def apply! *data
    @lister, @sorter, @time, @data = data
    self
  end

  def clone
    List::zero.apply! @lister, @sorter, @time, @data.dup
  end

  def add! other
    other.each do |ds|
      self << ds
    end
    self
  end

  def mul! other
    @data.delete_if { | key, _ | !other.include?(key) }
    other.each do |ds|
      if self.include?(ds.object)
        self << ds
      end
    end
    self
  end

  def sub! other
    @data.delete_if { | key, _ | other.include?(key) }
    self
  end

  def add other
    clone.add! other
  end

  def mul other
    # А вот здесь будет эффективней старое решение
    result = List::new [], @lister, sorter: @sorter, time: @time
    @data.each do |key, ds|
      if other.include?(key)
        summa = ds | other[key]
        self << summa
      end
    end
    result
  end

  def sub other
    clone.sub! other
  end

  alias :+ :add
  alias :* :mul
  alias :- :sub

end
