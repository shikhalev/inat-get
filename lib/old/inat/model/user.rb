
require_relative 'model'
require_relative 'unique'
require_relative 'user/preferences'

class INat::Model::User < INat::Model::Unique

  field :site_id, type: Integer
  field :created_at, type: Time
  field :login, type: Symbol
  field :login_autocomplete, type: String
  field :login_exact, type: String
  field :spam, type: Md::Types::Bool
  field :suspended, type: Md::Types::Bool
  field :name, type: String
  field :name_autocomplete, type: String
  field :icon, type: URI
  field :icon_url, type: URI
  field :observations_count, type: Integer
  field :identifications_count, type: Integer
  field :journal_posts_count, type: Integer
  field :activity_count, type: Integer
  field :species_count, type: Integer
  field :universal_search_rank, type: Integer
  field :roles, type: Md::Types::List[Symbol]
  field :preferences, type: INat::Model::User::Preferences

  # TODO: Types
  field :orcid, type: String

end
