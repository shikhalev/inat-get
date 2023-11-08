# frozen_string_literal: true

require_relative '../globals'
require_relative '../config/messagelevel'

require_relative '../../data/entity/observation'
require_relative '../../data/query'
require_relative '../../data/sets/dataset'
require_relative '../../data/sets/list'

class Task; end

module Task::DSL

  include LogDSL

  def select **params
    query = Query::new(**params)
    DataSet::new nil, query.observations
  end

  module_function :select

end
