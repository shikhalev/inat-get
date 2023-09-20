# frozen_string_literal: true

require_relative 'dataset'
require_relative 'model/taxon'

class Item

  attr_reader :taxon
  attr_reader :observations

  def initialize taxon, observation
    @taxon = taxon
    @observation = observation
  end

  def id
    @taxon.id
  end

end

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
