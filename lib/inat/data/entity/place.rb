# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'

class Place < Entity

  path :places
  table :places

  # TODO: implement

end
