
require_relative '../dbo/entity'
require_relative './observation'
require_relative './user'
require_relative './flag'

class Comment < ING::DBO::Entity

  table :comments

  field :uuid, type: UUID, unique: true
  field :observation, type: Observation, index: true
  field :user, type: User, index: true
  field :created_at, type: Time, index: true
  field :body, type: Text
  field :hidden, type: Boolean, index: true

  links :flags, type: Flag, owned: true

  register

end

# ING::DBO::DDL.register Comment
