# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'
require_relative '../types/wrapper'
require_relative 'flag'

class Photo < Entity

  table :photos

  field :license_code, type: Symbol, index: true
  field :url, type: URI
  field :square_url, type: URI
  field :medium_url, type: URI
  field :small_url, type: URI
  field :large_url, type: URI
  field :original_url, type: URI
  field :attribution, type: String
  field :hidden, type: Boolean, index: true

  links :flags, type: List[Flag], ids_name: :flag_ids

  # TODO: сделать нормальный тип
  field :original_dimensions, type: Wrapper

  # TODO: разобраться
  field :moderator_actions, type: Wrapper
  field :native_page_url, type: URI
  field :native_photo_id, type: Wrapper

end

DDL::register Photo
