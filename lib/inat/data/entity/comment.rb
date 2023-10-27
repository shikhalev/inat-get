# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'
autoload :User,        'inat/data/entity/user'
autoload :Flag,        'inat/data/entity/flag'

class Comment < Entity

  table :comments

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :user, type: User, index: true
  field :created_at, type: Time, required: true
  field :body, type: String
  field :hidden, type: Boolean, index: true

  links :flags, item_type: Flag, owned: true

  ignore :moderator_actions      # TODO: разобраться

  ignore :created_at_details

end
