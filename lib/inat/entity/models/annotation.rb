# frozen_string_literal: true

require_relative '../entity'
require_relative 'observation'

class Annotation < Entity

  table :annotations

  field :observation, type: Observation, index: true

end