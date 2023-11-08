# frozen_string_literal: true

require 'extra/uuid'

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

# require_relative 'observation'
# require_relative 'sound'

# class Observation < Entity; end

autoload :Observation, 'inat/data/entity/observation'
autoload :Sound,       'inat/data/entity/sound'

class ObservationSound < Entity

  table :observation_sounds

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :sound, type: Sound, required: true

end
