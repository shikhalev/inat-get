# frozen_string_literal: true

require_relative 'dataset'

class List

  def initialize task, dataset = nil
    @task = task
    # TODO:
  end

  def each sort: :id, &block
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

  def << observation_or_taxon_or_dataset
    # TODO:
  end

  def select **query
    # TODO:
  end

end
