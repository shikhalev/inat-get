# frozen_string_literal: true

class DataSet

  attr_reader :time
  attr_reader :object
  attr_reader :observations

  def initialize object, observations, time: Time::new
    @object = object
    @time = time
    @observations = observations
  end

  include Enumerable

  def each
    # NEED: implement
  end

  def split *args
    # NEED: implement
  end

  def to_list normalize: (Rank::COMPLEX .. Rank::HYBRID)
    # NEED: implement
  end

  def include? observation
    # NEED: implement
  end

  def where **params, &block
    # Filter contents and return values as a DataSet
    # NEED: implement
  end

  alias :include? :===

  def | other
    # NEED: implement
  end

  def & other
    # NEED: implement
  end

  def - other
    # NEED: implement
  end

end
