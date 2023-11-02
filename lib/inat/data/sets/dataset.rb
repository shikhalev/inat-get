# frozen_string_literal: true

class DataSet

  attr_reader :object
  attr_reader :observations

  def initialize object, observations
    @object = object
    @observations = observations
  end

  include Enumerable

  def each
    # NEED: implement
  end

  def group_by *args
    # NEED: implement
  end

end
