# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../types/location'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'

class Place < Entity

  path :places
  table :places

  field :uuid, type: UUID, unique: true
  field :name, type: String, index: true, required: true
  field :slug, type: Symbol, index: true
  field :display_name, type: String, index: true
  field :bbox_area, type: Float
  field :admin_level, type: Integer, index: true
  field :place_type, type: Integer, index: true
  field :location, type: Location

  ignore :geometry_geojson                  # TODO: implement
  ignore :bounding_box_geojson

  links :ancestor_places, item_type: Place, table_name: :place_ancestors, link_field: :ancestor_id, index: true

  def === other
    self.id == other.id && other.ancestor_place_ids.include?(self.id)
  end

  class << self

    def DDL
      super +
      "INSERT OR REPLACE INTO places (id, uuid, name, display_name) VALUES (59614, '00000000-0000-0000-0000-000000000000', 'World', 'Весь мир');\n"
      # Если верить API, то идентификатор такой есть, а записи для него нет.
      #   Вставляем ему искусственно некоторые данные для того, чтобы не запрашивать впустую каждый раз, как он встречается.
    end

  end

end
