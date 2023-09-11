
require_relative 'model'
require_relative 'user'
require_relative 'controlled_term'
require_relative 'controlled_value'

class INat::Model::Annotation < INat::Model

  field :controlled_attribute_id, type: Integer
  field :controlled_value_id, type: Integer
  field :concatenated_attr_val, type: String
  field :user_id, type: Integer
  field :user, type: INat::Model::User
  field :controlled_attribute, type: INat::Model::ControlledTerm
  field :controlled_value, type: INat::Model::ControlledValue

  # TODO: Types
  field :uuid
  field :vote_score
  field :votes

end
