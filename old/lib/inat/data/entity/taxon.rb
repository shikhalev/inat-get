# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

require_relative '../enums/rank'
require_relative '../enums/iconictaxa'

require_relative 'photo'

module INat::Entity
  autoload :Observation, 'inat/data/entity/observation'
end

class INat::Entity::Taxon < INat::Data::Entity

  include INat::Data::Types
  include INat::Entity

  api_path :taxa
  api_part :query
  api_limit 200

  table :taxa

  # @!group Fields

  field :is_active, type: Boolean, index: true
  # field :ancestry, type: Ancestry
  # field :min_species_ancestry, type: Ancestry
  field :endemic, type: Boolean
  field :iconic_taxon, type: Taxon
  field :min_species_taxon, type: Taxon
  field :threatened, type: Boolean, index: true
  field :rank_level, type: Float, index: true
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
  # field :observations_count, type: Integer
  field :photos_locked, type: Boolean
  # field :universal_search_rank, type: Integer
  field :wikipedia_url, type: URI
  field :wikipedia_summary, type: String
  field :iconic_taxon_name, type: IconicTaxa, index: true
  # field :iconic_taxon, type: Taxon, index: true
  field :preferred_common_name, type: String
  field :english_common_name, type: String
  field :vision, type: Boolean

  links :ancestors, item_type: Taxon, link_field: :ancestor_id
  links :taxon_photos, item_type: Photo, table_name: :taxon_photos

  backs :children, item_type: Taxon, ids_field: :child_ids, back_field: :parent_id, owned: false

  ignore :flag_counts                         # TODO: разобраться
  ignore :current_synonymous_taxon_ids
  ignore :atlas_id
  ignore :complete_species_count
  ignore :conservation_statuses
  ignore :conservation_status
  ignore :listed_taxa
  ignore :complete_rank

  ignore :ancestry                            # TODO: подумать и сделать обязательно
  ignore :min_species_ancestry
  ignore :establishment_means
  ignore :preferred_establishment_means

  ignore :observations_count
  ignore :universal_search_rank

  # @!endgroup

  def === other
    other.id == self.id || other.ancestor_ids.include?(self.id)
  end

  def sort_key
    [ iconic_taxon_name || IconicTaxa::UNKNOWN, name ]
  end

  private def prepare_name name
    name.downcase.gsub(' ', ' ').capitalize
  end

  def to_s
    if preferred_common_name
      "<a href=\"https://www.inaturalist.org/taxa/#{ id }\"><i class=\"icon-iconic-#{ (iconic_taxon_name || IconicTaxa::UNKNOWN).to_s.downcase }\" style=\"font-size:1.5em;height:1em;line-height:1em;\"></i> #{ prepare_name(preferred_common_name) } <i>(#{ prepare_name(name) })</i></a>"
    else
      "<a href=\"https://www.inaturalist.org/taxa/#{ id }\"><i class=\"icon-iconic-#{ (iconic_taxon_name || IconicTaxa::UNKNOWN).to_s.downcase }\" style=\"font-size:1.5em;height:1em;line-height:1em;\"></i> <i>#{ prepare_name(name) }</i></a>"
    end
  end

end
