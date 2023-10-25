# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'

class User < Entity

  path :users
  table :users

  field :login, type: String, index: true, required: true
  field :spam, type: Boolean
  field :suspended, type: Boolean, index: true
  field :created_at, type: Time, index: true
  field :site_id, type: Integer, index: true
  field :login_autocomplete, type: String
  field :login_exact, type: String
  field :name, type: String, index: true
  field :name_autocomplete, type: String
  field :orcid, type: URI
  field :icon, type: URI
  field :icon_url, type: URI
  field :observations_count, type: Integer
  field :identifications_count, type: Integer
  field :journal_posts_count, type: Integer
  field :activity_count, type: Integer
  field :species_count, type: Integer
  field :universal_search_rank, type: Integer

  ignore :roles                   # TODO: разобраться
  ignore :preferences

end
