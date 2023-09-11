
require_relative 'model'
require_relative 'unique'
require_relative 'user'

class INat::Model::Vote < INat::Model::Unique

  field :vote_flag, type: Md::Types::Bool
  field :user_id, type: Integer
  field :created_at, type: Time
  field :user, type: INat::Model::User

  # TODO: Types
  field :vote_scope

end
