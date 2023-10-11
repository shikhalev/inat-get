# frozen_string_literal: true

class DataSet

  include Enumerable

  def initialize cache, observations
    @cache = cache
    @observations = observations
  end

  def each sort: :id, &block
    # TODO:
  end

  def empty?
    @observations.empty?
  end

  def size
    @observations.size
  end

  def observations
    @observations.dup.freeze
  end

  def + other
    # TODO:
  end

  def - other
    # TODO:
  end

  def * other
    # TODO:
  end

  def << observation
    # TODO:
  end

  def select **query
    # TODO:
  end

end
