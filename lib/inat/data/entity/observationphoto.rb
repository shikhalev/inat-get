# frozen_string_literal: true

require 'extra/uuid'

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'
autoload :Photo,       'inat/data/entity/photo'

class ObservationPhoto < Entity

  table :observation_photos

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :position, type: Integer, index: true
  field :photo, type: Photo, required: true

end
