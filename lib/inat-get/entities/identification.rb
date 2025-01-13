
require_relative '../dbo/entity'
require_relative './taxon'
require_relative './observation'

class Identification < ING::DBO::Entity

  table :identifications

  field :uuid, type: UUID, unique: true
  field :observation, type: Observation, index: true
  field :user, type: User, index: true
  field :created_at, type: Time, index: true
  field :body, type: Text
  field :category, type: Symbol, index: true
  field :current, type: Boolean
  field :own_observation, type: Boolean, index: true
  field :vision, type: Boolean, index: true
  field :disagreement, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :hidden, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :previous_observation_taxon, type: Taxon, index: true

  links :flags, type: Flag, owned: true

  register

end

# ING::DBO::DDL.register Identification
