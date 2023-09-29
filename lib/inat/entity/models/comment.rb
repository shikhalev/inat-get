# frozen_string_literal: true

require_relative '../entity'

class Comment < Entity

  table :comments

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :user, type: User, index: true
  field :created_at, type: Time
  field :body, type: String
  field :hidden, type: Boolean, index: true

  links :flags, type: List[Flag], ids_name: :flag_ids

  # TODO: разобраться
  field :moderator_actions, type: Wrapper

end
