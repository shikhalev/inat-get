# frozen_string_literal: true

require_relative '../entity'

class Place < Entity

  path :places
  table :places

  field :uuid, type: UUID, unique: true
  field :name, type: String, index: true, required: true
  field :slug, type: Symbol, index: true
  field :display_name, type: String, index: true
  field :bounding_box_geojson, type: GeoJSON
  field :bbox_area, type: Float
  field :admin_level, type: Integer, index: true
  field :place_type, type: Integer, index: true
  field :location, type: Location
  field :geometry_geojson, type: GeoJSON

  links :ancestor_places, type: List[Place], ids_name: 'ancestor_place_ids', table: :place_ancestors, linkfield: :ancestor_id, index: true

  def === other
    self.id == other.id && other.ancestor_place_ids.include?(self.id)
  end

end
