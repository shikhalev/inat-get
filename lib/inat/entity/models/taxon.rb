# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'
require_relative '../types/wrapper'
require_relative '../types/ancestry'
require_relative 'photo'

class Taxon < Entity

  path :taxa
  table :taxa

  field :is_active, type: Boolean, index: true
  field :ancestry, type: Ancestry
  field :min_species_ancestry, type: Ancestry
  field :endemic, type: Boolean
  field :iconic_taxon, type: Taxon
  field :min_species_taxon, type: Taxon
  field :threatened, type: Boolean, index: true
  field :rank_level, type: Integer
  field :introduced, type: Boolean
  field :native, type: Boolean
  field :parent, type: Taxon
  field :name, type: String, index: true, required: true
  field :rank, type: Symbol, index: true
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
  field :iconic_taxon_name, type: Symbol, index: true
  field :preferred_common_name, type: String
  field :english_common_name, type: String
  field :vision, type: Boolean

  links :ancestors, type: List[Taxon], ids_name: :ancestor_ids, linkfield: :ancestor_id
  links :taxon_photos, type: List[Photo], table: :taxon_photos, ids_name: :taxon_photo_ids

  backs :children, type: List[Taxon], ids_name: :child_ids, backfield: :parent, own: false

  # TODO: разобраться
  field :flag_counts, type: Wrapper
  field :current_synonymous_taxon_ids, type: Wrapper
  field :atlas_id, type: Wrapper
  field :complete_species_count, type: Wrapper
  field :conservation_statuses, type: Wrapper
  field :conservation_status, type: Wrapper
  field :listed_taxa, type: Wrapper

  def === other
    other.id == self.id || other.ancestor_ids.include?(self.id)
  end

end

DDL::register Taxon
