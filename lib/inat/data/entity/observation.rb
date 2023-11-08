# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../types/location'
require_relative '../entity'
require_relative '../enums/qualitygrade'
require_relative '../enums/licensecode'
require_relative '../enums/geoprivacy'

autoload :Taxon,            'inat/data/entity/taxon'
autoload :User,             'inat/data/entity/user'
autoload :Flag,             'inat/data/entity/flag'
autoload :ObservationSound, 'inat/data/entity/observationsound'
autoload :Sound,            'inat/data/entity/sound'
autoload :ObservationPhoto, 'inat/data/entity/observationphoto'
autoload :Photo,            'inat/data/entity/photo'
autoload :Place,            'inat/data/entity/place'
autoload :Project,          'inat/data/entity/project'
autoload :Comment,          'inat/data/entity/comment'
autoload :Identification,   'inat/data/entity/identification'
autoload :Vote,             'inat/data/entity/vote'

class Observation < Entity

  api_path :observations
  api_part :query
  api_limit 200

  table :observations

  field :quality_grade, type: QualityGrade, required: true, index: true
  field :uuid, type: UUID, unique: true
  field :species_guess, type: String
  field :license_code, type: LicenseCode, index: true
  field :description, type: String
  field :captive, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :community_taxon, type: Taxon, index: true
  field :uri, type: URI
  field :obscured, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :user, type: User, index: true
  field :mappable, type: Boolean, index: true

  links :flags, item_type: Flag, owned: true

  field :time_observed_at, type: Time, index: true
  field :created_at, type: Time, index: true
  field :observed_on, type: Date, index: true
  field :observed_on_string, type: String
  field :updated_at, type: Time, index: true

  field :geoprivacy, type: GeoPrivacy, index: true
  field :taxon_geoprivacy, type: GeoPrivacy, index: true
  field :location, type: Location, index: true
  field :positional_accuracy, type: Integer, index: true
  field :public_positional_accuracy, type: Integer, index: true
  field :place_guess, type: String

  backs :observation_sounds, item_type: ObservationSound, owned: true
  links :sounds, item_type: Sound, table_name: :observation_sounds, owned: false
  backs :observation_photos, item_type: ObservationPhoto, owned: true
  links :photos, item_type: Photo, table_name: :observation_photos, owned: false

  links :places, item_type: Place, owned: true
  links :projects, item_type: Project, owned: true                       # Это только ручные
  links :cached_projects, item_type: Project, table_name: :project_observations, owned: false

  field :owners_identification_from_vision, type: Boolean
  field :identifications_most_agree, type: Boolean
  field :identifications_some_agree, type: Boolean
  field :num_identification_agreements, type: Integer
  field :identifications_most_disagree, type: Boolean
  field :num_identification_disagreements, type: Integer
  backs :comments, item_type: Comment, owned: true
  backs :identifications, item_type: Identification, owned: true

  links :ident_taxa, item_type: Taxon, ids_field: :ident_taxon_ids, index: true, owned: true

  links :votes, item_type: Vote, owned: true
  links :faves, item_type: Vote, owned: true

  field :day, type: Integer, index: true
  field :month, type: Integer, index: true
  field :year, type: Integer, index: true

  block :observed_on_details, type: Hash do |value|
    if Hash === value
      self.day   = value['day']
      self.month = value['month']
      self.year  = value['year']
    end
  end

  field :endemic, type: Boolean, index: true
  field :introduced, type: Boolean, index: true
  field :native, type: Boolean, index: true
  field :taxon_is_active, type: Boolean, index: true
  field :threatened, type: Boolean, index: true
  field :photo_licensed, type: Boolean, index: true
  field :rank, type: Rank, index: true

  def post_update
    t = self.taxon
    if t
      self.endemic = t.endemic
      self.introduced = t.introduced
      self.native = t.native
      self.taxon_is_active = t.is_active
      self.threatened = t.threatened
      self.rank = t.rank
    end
    if self.observation_photos != nil
      self.photo_licensed = self.observation_photos.any? { |p| p.photo.license_code != nil }
    end
  end

  def normalized_taxon ranks
    ranks = (ranks .. ranks) if Rank === ranks
    raise TypeError, "Invalid type for ranks: #{ ranks.inspect }!", caller unless Range === ranks
    min = ranks.begin
    # max = ranks.end
    taxon = self.taxon
    while true do
      return nil if taxon == nil
      return nil if taxon.rank < min
      return taxon if ranks === taxon.rank
      taxon = taxon.parent
    end
  end

  def sort_key
    time_observed_at
  end

  ignore :tags                # TODO: implement
  ignore :created_time_zone   # TODO: подумать...
  ignore :observed_time_zone
  ignore :time_zone_offset
  ignore :geojson
  ignore :annotations
  # ignore :observed_on_details
  ignore :created_at_details
  ignore :cached_votes_total
  ignore :comments_count
  ignore :site_id
  ignore :quality_metrics
  ignore :reviewed_by
  ignore :oauth_application_id
  ignore :project_ids_with_curator_id
  # ignore :place_ids
  ignore :outlinks             # NEED
  ignore :faves_count
  ignore :ofvs
  ignore :preferences
  ignore :map_scale
  ignore :identifications_count
  ignore :project_ids_without_curator_id
  ignore :project_observations  # TODO: ???
  ignore :non_owner_ids

end
