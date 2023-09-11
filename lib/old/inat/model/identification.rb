
require_relative 'model'
require_relative 'unique'
require_relative 'user'
require_relative 'taxon'
require_relative 'date_details'

class INat::Model::Identification < INat::Model::Unique

  field :hidden, type: Md::Types::Bool
  field :disagreement, type: Md::Types::Bool
  field :created_at, type: Time
  field :created_at_details, type: INat::Model::DateDetails
  field :taxon_id, type: Integer
  field :body, type: String
  field :own_observation, type: Md::Types::Bool
  field :vision, type: Md::Types::Bool
  field :current, type: Md::Types::Bool
  field :category, type: Symbol
  field :spam, type: Md::Types::Bool
  field :user, type: INat::Model::User
  field :previous_observation_taxon_id, type: Integer
  field :taxon, type: INat::Model::Taxon
  field :previous_observation_taxon, type: INat::Model::Taxon

  # TODO: Types
  field :flags
  field :uuid
  field :taxon_change
  field :moderator_actions

end
