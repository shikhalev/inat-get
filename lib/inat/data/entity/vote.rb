# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'
autoload :User,        'inat/data/entity/user'

class Vote < Entity

  table :votes

  # field :observation, type: Observation, index: true, required: true

  field :created_at, type: Time, index: true, required: true
  field :vote_flag, type: Boolean, index: true
  field :user, type: User, index: true

  ignore :vote_scope              # TODO: разобраться

end
