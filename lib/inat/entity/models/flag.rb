# frozen_string_literal: true

require_relative '../entity'

autoload :User, 'inat/entity/models/user'

class Flag < Entity

  table :flags

  field :flag, type: String, required: true
  field :created_at, type: Time
  field :updated_at, type: Time
  field :user, type: User, index: true
  field :resolved, type: Boolean, index: true
  field :resolver, type: User, index: true
  field :comment, type: String

end
