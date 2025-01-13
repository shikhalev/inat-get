
require_relative '../dbo/entity'
require_relative './taxon'
require_relative './user'

# Чтобы не заморачиваться с autoload
class Comment < ING::DBO::Entity; end
class Identification < ING::DBO::Entity; end

class Observation < ING::DBO::Entity

  table :observation

  field :uuid, type: UUID, unique: true
  field :quality_grade, type: Symbol, required: true, index: true
  field :species_guess, type: Text
  field :license_code, type: Symbol, index: true
  field :description, type: Text
  field :captive, type: Boolean, index: true
  field :taxon, type: Taxon, index: true
  field :community_taxon, type: Taxon, index: true
  field :uri, type: URI
  field :obscured, type: Boolean, index: true
  field :spam, type: Boolean, index: true
  field :user, type: User, index: true
  field :mappable, type: Boolean, index: true

  field :observed_at, type: Time, index: true, source_aliases: [ :time_observed_at ]
  field :created_at, type: Time, index: true
  field :observed_on, type: Date, index: true
  field :observed_on_string, type: Text
  field :updated_at, type: Time, index: true

  field :geoprivacy, type: Symbol, index: true
  field :taxon_geoprivacy, type: Symbol, index: true
  field :location, type: Location, index: true
  field :positional_accuracy, type: Integer, index: true
  field :public_positional_accuracy, type: Integer, index: true
  field :place_guess, type: Text

  backs :identifications, type: Identification
  backs :comments, type: Comment

  register

end

# ING::DBO::DDL.register Observation
