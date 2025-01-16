# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

module INat::Entity
  autoload :Observation, 'inat/data/entity/observation'
  autoload :User,        'inat/data/entity/user'
end

class INat::Entity::Flag < INat::Data::Entity

  include INat::Entity

  table :flags

  field :flag, type: String, required: true
  field :created_at, type: Time
  field :updated_at, type: Time
  field :user, type: User, index: true, required: true
  field :resolved, type: Boolean, index: true
  field :resolver, type: User, index: true
  field :comment, type: String

  ignore :flaggable_id

end
