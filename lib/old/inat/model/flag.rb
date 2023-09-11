
require_relative 'unique'
require_relative 'user'

class INat::Model::Flag < INat::Model::Unique

  field :flag, type: String
  field :updated_at, type: Time
  field :user_id, type: Integer
  field :resolver_id, type: Integer
  field :created_at, type: Time
  field :comment, type: String
  field :resolved, type: Md::Types::Bool
  field :user, type: INat::Model::User

end
