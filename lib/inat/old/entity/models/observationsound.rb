# frozen_string_literal: true

require_relative '../entity'

autoload :Sound, 'inat/entity/models/sound'

class ObservationSound < Entity

  table :observation_sounds

  field :observation, type: Observation, index: true, required: true

  field :uuid, type: UUID, unique: true
  field :sound, type: Sound, required: true

end
