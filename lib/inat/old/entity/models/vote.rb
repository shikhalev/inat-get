# frozen_string_literal: true

require_relative '../entity'

autoload :User, 'inat/entity/models/user'

class Vote < Entity

  table :votes

  field :observation, type: Observation, index: true, required: true

  field :created_at, type: Time, index: true, required: true
  field :vote_flag, type: Boolean, index: true
  field :user, type: User, index: true

  # TODO: разобраться
  field :vote_scope, type: Wrapper

end
