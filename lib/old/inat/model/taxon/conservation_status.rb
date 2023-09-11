
require_relative '../model'
require_relative '../unique'
require_relative '../mergeable'

class INat::Model::Taxon < INat::Model::Unique
end

class INat::Model::Taxon::ConservationStatus < INat::Model
  include INat::Model::Mergeable

  field :place_id, type: Integer
  field :source_id, type: Integer
  field :user_id, type: Integer
  field :authority, type: Symbol
  field :status, type: Symbol
  field :status_name, type: Symbol
  field :iucn, type: Integer

  # TODO: Types
  field :geoprivacy

end
