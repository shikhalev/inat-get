# frozen_string_literal: true

require 'time'
require 'date'

require_relative 'model'
require_relative 'withid'
require_relative 'types'

class Observation < WithId

  field :quality_grade, type: Symbol, index: true
  field :time_observed_at, type: Time, index: true
  field :taxon_geoprivacy, type: Symbol, index: true
  field :uuid, type: String, unique: true                     # TODO: UUID class?
  field :cached_votes_total, type: Integer
  field :identifications_most_agree, type: Bool
  field :identifications_most_disagree, type: Bool
  field :species_guess, type: String
  field :tags, type: Items[String]                            # TODO: подумать, возможно, выделить таблицу
  field :positional_accuracy, type: Float, index: true
  field :public_positional_accuracy, type: Float, index: true
  field :comments_count, type: Integer
  field :faves_count, type: Integer
  field :site_id, type: Integer, index: true
  field :created_time_zone, type: Symbol                      # TODO: подумать об отдельном типе
  field :observed_time_zone, type: Symbol
  field :license_code, type: Symbol, index: true
  field :created_at, type: Time, index: true
  field :description, type: String
  field :time_zone_offset, type: Symbol, index: true
  field :observed_on, type: Date, index: true
  field :updated_at, type: Time, index: true
  field :places, type: Items[Place], ids_name: :place_ids
  field :projects, type: Items[Project], ids_name: :projects_ids       # TODO: Учесть отсутствие в приходящих данных, заполнять из запросов
  field :captive, type: Bool, index: true
  field :taxon, type: Taxon, index: true
  field :community_taxon, type: Taxon, index: true
  field :ident_taxa, type: Items[Taxon], ids_name: :ident_taxon_ids    # TODO: ??? а нужно ли?
  field :num_identification_agreements, type: Integer
  field :num_identification_disagreements, type: Integer
  field :uri, type: URI
  field :owners_identification_from_vision, type: Bool
  field :identifications_count, type: Integer
  field :obscured, type: Bool
  field :spam, type: Bool
  field :user, type: User, index: true
  field :mappable, type: Bool
  field :identifications_some_agree, type: Bool
  field :place_guess, type: String

  # TODO: Пока непонятно как
  # field :annotations             backlink
  # field :comments                backlink
  # field :flags                   backlink?
  # field :identifications         backlink
  # field :quality_metrics         ???
  # field :reviewed_by             ids...
  # field :oauth_application_id
  # field :project_ids_with_curator_id
  # field :project_ids_without_curator_id
  # field :observation_sounds
  # field :sounds
  # field :observation_photos
  # field :photos
  # field :project_ids
  # field :outlinks                структура нужна
  # field :ofvs
  # field :preferences
  # field :map_scale
  # field :geojson                 структура нужна
  # field :geoprivacy
  # field :location                структура нужна (там координаты в строке)
  # field :votes
  # field :project_observations    что это?
  # field :faves
  # field :non_owner_ids           conditional backlink?

end
