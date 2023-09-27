# frozen_string_literal: true

require_relative '../entity'
require_relative 'declarations'

class Identification < Entity

  path :identifications
  table :identifications

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :user, type: User, index: true
  field :created_at, type: Time, index: true
  field :body, type: String
  field :category, type: Symbol, index: true
  field :current, type: Boolean
  field :own_observation, type: Boolean, index: true
  field :vision, type: Boolean
  field :disagreement, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :hidden, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :previous_observation_taxon, type: Taxon, index: true

  links :flags, type: List[Flag], ids_name: :flag_ids

  # TODO: разобраться
  # field :taxon_change
  # field :moderator_actions

end
