
require_relative 'model'
require_relative 'unique'
require_relative 'taxon'
require_relative 'outlink'
require_relative 'observation/preferences'
require_relative 'geojson'
require_relative 'vote'
require_relative 'user'
require_relative 'identification'
require_relative 'photo'
require_relative 'observation/photo'
require_relative 'annotation'
require_relative 'comment'
require_relative 'date_details'
require_relative 'sound'
require_relative 'observation/sound'
require_relative 'project_observation'

class INat::Model::Observation < INat::Model::Unique

  field :quality_grade, type: Symbol
  field :time_observed_at, type: Time
  field :taxon_geoprivacy, type: Symbol
  field :cached_votes_total, type: Integer
  field :identifications_most_agree, type: Md::Types::Bool
  field :identifications_most_disagree, type: Md::Types::Bool
  field :species_guess, type: String
  field :positional_accuracy, type: Float
  field :public_positional_accuracy, type: Float
  field :comments_count, type: Integer
  field :site_id, type: Integer
  field :oauth_application_id, type: Integer
  field :license_code, type: Symbol
  field :reviewed_by, type: Md::Types::List[Integer]
  field :created_at, type: Time
  field :description, type: String
  field :observed_on, type: Date
  field :observed_on_string, type: String
  field :updated_at, type: Time
  field :place_ids, type: Md::Types::List[Integer]
  field :captive, type: Md::Types::Bool
  field :ident_taxon_ids, type: Md::Types::List[Integer]
  field :faves_count, type: Integer
  field :num_identification_agreements, type: Integer
  field :uri, type: String
  field :project_ids, type: Md::Types::List[Integer]
  field :community_taxon_id, type: Integer
  field :owners_identification_from_vision, type: Md::Types::Bool
  field :identifications_count, type: Integer
  field :obscured, type: Md::Types::Bool
  field :num_identification_disagreements, type: Integer
  field :spam, type: Md::Types::Bool
  field :mappable, type: Md::Types::Bool
  field :identifications_some_agree, type: Md::Types::Bool
  field :project_ids_with_curator_id, type: Md::Types::List[Integer]
  field :project_ids_without_curator_id, type: Md::Types::List[Integer]
  field :place_guess, type: String

  field :taxon, type: INat::Model::Taxon
  field :outlinks, type: Md::Types::List[INat::Model::OutLink]
  field :preferences, type: INat::Model::Observation::Preferences
  field :geojson, type: INat::Model::GeoJSON
  field :geoprivacy, type: Symbol
  field :votes, type: Md::Types::List[INat::Model::Vote]
  field :user, type: INat::Model::User
  field :identifications, type: Md::Types::List[INat::Model::Identification]
  field :photos, type: Md::Types::List[INat::Model::Photo]
  field :observation_photos, type: Md::Types::List[INat::Model::Observation::Photo]
  field :faves, type: Md::Types::List[INat::Model::Vote]
  field :non_owner_ids, type: Md::Types::List[INat::Model::Identification]
  field :annotations, type: Md::Types::List[INat::Model::Annotation]
  field :tags, type: Md::Types::List[String]
  field :comments, type: Md::Types::List[INat::Model::Comment]
  field :observed_on_details, type: INat::Model::DateDetails
  field :created_at_details, type: INat::Model::DateDetails
  field :sounds, type: Md::Types::List[INat::Model::Sound]
  field :observation_sounds, type: Md::Types::List[INat::Model::Observation::Sound]
  field :community_taxon, type: INat::Model::Taxon
  field :project_observations, type: Md::Types::List[INat::Model::ProjectObservation]
  field :flags, type: Md::Types::List[INat::Model::Flag]
  field :created_time_zone, type: Symbol
  field :observed_time_zone, type: Symbol

  # TODO: Types
  field :quality_metrics
  field :ofvs
  field :uuid
  field :time_zone_offset
  field :map_scale
  field :location

end
