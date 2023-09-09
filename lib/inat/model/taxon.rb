
require_relative 'model'
require_relative 'unique'
require_relative 'photo'

class INat::Model::Taxon < INat::Model::Unique

  field :is_active, type: Md::Types::Bool
  field :endemic, type: Md::Types::Bool
  field :iconic_taxon_id, type: Integer
  field :min_species_taxon_id, type: Integer
  field :threatened, type: Md::Types::Bool
  field :rank_level, type: Integer
  field :introduced, type: Md::Types::Bool
  field :native, type: Md::Types::Bool
  field :parent_id, type: Integer
  field :name, type: Symbol
  field :rank, type: Symbol
  field :extinct, type: Md::Types::Bool
  field :ancestor_ids, type: Md::Types::List[Integer]
  field :photos_locked, type: Md::Types::Bool
  field :taxon_schemes_count, type: Integer
  field :wikipedia_url, type: String
  field :created_at, type: Time
  field :taxon_changes_count, type: Integer
  field :complete_species_count, type: Integer
  field :universal_search_rank, type: Integer
  field :observations_count, type: Integer
  field :atlas_id, type: Integer
  field :iconic_taxon_name, type: Symbol
  field :preferred_common_name, type: String
  field :complete_rank, type: Symbol
  field :ancestors, type: Md::Types::List[INat::Model::Taxon]

  field :default_photo, type: INat::Model::Photo

  # TODO: types
  field :ancestry
  field :min_species_ancestry
  field :current_synonymous_taxon_ids

  # TODO: типы в первую очередь
  field :flag_counts

end
