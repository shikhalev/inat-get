# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

require_relative '../enums/rank'
require_relative '../enums/iconictaxa'

autoload :Observation, 'inat/data/entity/observation'

class Taxon < Entity

  path :taxa
  table :taxa

  field :is_active, type: Boolean, index: true
  # field :ancestry, type: Ancestry
  # field :min_species_ancestry, type: Ancestry
  field :endemic, type: Boolean
  field :iconic_taxon, type: Taxon
  field :min_species_taxon, type: Taxon
  field :threatened, type: Boolean, index: true
  field :rank_level, type: Integer, index: true
  field :introduced, type: Boolean
  field :native, type: Boolean
  field :parent, type: Taxon
  field :name, type: String, index: true, required: true
  field :rank, type: Rank, index: true
  field :extinct, type: Boolean
  field :created_at, type: Time
  field :default_photo, type: Photo
  field :taxon_changes_count, type: Integer
  field :taxon_schemes_count, type: Integer
  field :observations_count, type: Integer
  field :photos_locked, type: Boolean
  field :universal_search_rank, type: Integer
  field :wikipedia_url, type: URI
  field :wikipedia_summary, type: String
  field :iconic_taxon_name, type: IconicTaxa, index: true
  field :preferred_common_name, type: String
  field :english_common_name, type: String
  field :vision, type: Boolean

  links :ancestors, item_type: Taxon, link_field: :ancestor_id
  links :taxon_photos, item_type: Photo

  backs :children, item_type: Taxon, ids_field: :child_ids, back_field: :parent_id, owned: false

  ignore :flag_counts                         # TODO: разобраться
  ignore :current_synonymous_taxon_ids
  ignore :atlas_id
  ignore :complete_species_count
  ignore :conservation_statuses
  ignore :conservation_status
  ignore :listed_taxa

  def === other
    other.id == self.id || other.ancestor_ids.include?(self.id)
  end


end