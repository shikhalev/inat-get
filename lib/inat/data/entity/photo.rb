# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

autoload :Observation, 'inat/data/entity/observation'

class Photo < Entity

  table :photos

  field :license_code, type: Symbol, index: true
  field :url, type: URI, required: true
  field :square_url, type: URI
  field :medium_url, type: URI
  field :small_url, type: URI
  field :large_url, type: URI
  field :original_url, type: URI
  field :attribution, type: String
  field :hidden, type: Boolean, index: true

  links :flags, item_type: Flag

  ignore :original_dimensions                     # TODO: сделать нормальный тип

  ignore :moderator_actions                       # TODO: разобраться
  field :native_page_url, type: URI
  ignore :native_photo_id

end
