# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'
require_relative 'observation'

class ObservationSound < Entity

  table :observation_sounds

  field :observation, type: Observation, index: true, required: true

  field :uuid, type: UUID, unique: true
  field :sound, type: Sound, required: true

end

DDL::register ObservationSound
