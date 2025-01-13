
require_relative '../dbo/entity'
require_relative './user'

class Flag < ING::DBO::Entity

  table :flags

  field :flag, type: Text, required: true
  field :created_at, type: Time
  field :updated_at, type: Time
  field :user, type: User, index: true, required: true
  field :resolved, type: Boolean, index: true
  field :resolver, type: User, index: true
  field :comment, type: Text

  register

end

# ING::DBO::DDL.register Flag
