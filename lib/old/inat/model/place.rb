
require_relative 'unique'
require_relative 'geojson'

class INat::Model::Place < INat::Model::Unique

  field :ancestor_place_ids, type: Md::Types::List[Integer]
  field :place_type, type: Integer
  field :name, type: String
  field :display_name, type: String
  field :slug, type: String
  field :admin_level, type: Integer
  field :bounding_box_geojson, type: INat::Model::GeoJSON
  field :geometry_geojson, type: INat::Model::GeoJSON
  field :bbox_area, type: Float

  # TODO: Types
  field :location
  field :uuid

end
