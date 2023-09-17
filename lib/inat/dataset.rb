# frozen_string_literal: true

class DataSet

  include Enumerable

  def initialize task, **query
    @task = task
    # TODO:
  end

  def each sort: :id, &block
    # TODO:
  end

  def fetch!
    # TODO:
  end

  def fetched?
    # TODO:
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
