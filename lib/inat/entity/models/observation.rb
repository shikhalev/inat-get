# frozen_string_literal: true

require 'time'
require 'date'

require_relative '../entity'
require_relative '../types/uuid'
require_relative '../types/tags'
require_relative '../types/geojson'
require_relative '../types/location'
require_relative 'taxon'
require_relative 'user'
require_relative 'flag'
require_relative 'sound'
require_relative 'observationsound'
require_relative 'photo'
require_relative 'observationphoto'
require_relative 'place'
require_relative 'project'
require_relative 'annotation'
require_relative 'comment'
require_relative 'identification'

class Observation < Entity

  path :observations
  table :observations

  field :quality_grade, type: Symbol, index: true
  field :uuid, type: UUID, unique: true
  field :species_guess, type: String
  field :tags, type: Tags
  field :license_code, type: Symbol, index: true
  field :description, type: String
  field :captive, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :community_taxon, type: Taxon, index: true
  field :uri, type: URI
  field :obscured, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :user, type: User, index: true
  field :mappable, type: Boolean

  links :flags, type: List[Flag], ids_name: :flag_ids

  # Time related fields
  field :created_time_zone, type: Symbol                              # TODO: сделать нормальные таймзоны
  field :observed_time_zone, type: Symbol
  field :time_zone_offset, type: Symbol
  field :time_observed_at, type: Time, index: true
  field :created_at, type: Time, index: true
  field :observed_on, type: Date, index: true
  field :observed_on_string, type: String
  field :updated_at, type: Time, index: true

  # Geo related fields
  field :taxon_geoprivacy, type: Symbol, index: true
  field :positional_accuracy, type: Integer, index: true
  field :public_positional_accuracy, type: Integer, index: true
  field :geojson, type: GeoJSON
  field :geoprivacy, type: Symbol, index: true
  field :location, type: Location
  field :place_guess, type: String

  # Media related fields
  links :sounds, type: List[Sound], ids_name: :sound_ids
  backs :observation_sounds, type: List[ObservationSound], ids_name: :observation_sound_ids, backfield: :observation
  links :photos, type: List[Photo], ids_name: :photo_ids
  backs :observation_photos, type: List[ObservationPhoto], ids_name: :observation_photo_ids, backfield: :observation

  # Projects and places
  links :places, type: List[Place], ids_name: :place_ids, index: true
  links :projects, type: List[Project], ids_name: :project_ids, index: true                 # Это только ручные проекты

  # Identification related fields
  field :owners_identification_from_vision, type: Boolean
  field :identifications_most_agree, type: Boolean
  field :identifications_some_agree, type: Boolean
  field :num_identification_agreements, type: Integer
  field :identifications_most_disagree, type: Boolean
  field :num_identification_disagreements, type: Integer
  backs :annotations, type: List[Annotation], ids_name: :annotation_ids, backfield: :observation
  backs :comments, type: List[Comment], ids_name: :comment_ids, backfield: :observation
  backs :identifications, type: List[Identification], ids_name: :identification_ids, backfield: :observation


  # FIXME: обязательные
  field :outlinks, type: Wrapper
  # field :ofvs
  # field :votes
  # field :faves

  # TODO: в последнюю очередь
  # field :quality_metrics
  # field :reviewed_by
  # field :oauth_application_id
  # field :project_ids_with_curator_id
  # field :project_ids_without_curator_id
  # field :project_observations
  # field :ident_taxon_ids
  # field :preferences
  # field :map_scale
  # backs :non_owner_ids

  # TODO: фильтрация по тегам

end
