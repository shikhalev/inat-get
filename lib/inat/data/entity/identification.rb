# frozen_string_literal: true

require 'extra/uuid'

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

require_relative '../enums/identificationcategory'

module INat::Entity
  autoload :Observation, 'inat/data/entity/observation'
  autoload :Taxon,       'inat/data/entity/taxon'
  autoload :Flag,        'inat/data/entity/flag'
end

class INat::Entity::Identification < INat::Data::Entity

  include INat::Data::Types
  include INat::Entity

  api_path :identifications
  api_part :query
  api_limit 200

  table :identifications

  field :observation, type: Observation, index: true

  field :uuid, type: UUID, unique: true
  field :user, type: User, index: true, required: true
  field :created_at, type: Time, index: true
  field :body, type: String
  field :category, type: IdentificationCategory, index: true
  field :current, type: Boolean
  field :own_observation, type: Boolean, index: true
  field :vision, type: Boolean
  field :disagreement, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :hidden, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :previous_observation_taxon, type: Taxon, index: true

  links :flags, item_type: Flag

  ignore :taxon_change                    # TODO: разобраться
  ignore :moderator_actions
  ignore :created_at_details

end
