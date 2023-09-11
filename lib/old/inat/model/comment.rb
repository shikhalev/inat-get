
require_relative 'model'
require_relative 'unique'
require_relative 'user'
require_relative 'date_details'

class INat::Model::Comment < INat::Model::Unique

  field :hidden, type: Md::Types::Bool
  field :created_at, type: Time
  field :created_at_details, type: INat::Model::DateDetails
  field :body, type: String
  field :user, type: INat::Model::User

  # TODO: Types
  field :moderator_actions
  field :flags
  field :uuid

end
