# frozen_string_literal: true

require_relative '../entity'

autoload :Photo, 'inat/entity/models/photo'

class ObservationPhoto < Entity

  table :observation_photos

  field :observation, type: Observation, index: true, required: true

  field :uuid, type: UUID, unique: true
  field :position, type: Integer, index: true
  field :photo, type: Photo, required: true

end
