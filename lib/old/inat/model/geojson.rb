
require_relative 'model'

class INat::Model::GeoJSON < INat::Model

  field :type, type: Symbol

  # TODO: Types
  field :coordinates
end
