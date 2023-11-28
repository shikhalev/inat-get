# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

module INat::Entity
  autoload :Observation, 'inat/data/entity/observation'
end

class INat::Entity::Sound < INat::Data::Entity

  include INat::Data::Types
  include INat::Entity

  table :sounds

  field :license_code, type: LicenseCode, index: true
  field :attribution, type: String
  field :file_url, type: URI
  field :file_content_type, type: Symbol, index: true
  field :play_local, type: Boolean
  field :subtype, type: Symbol, index: true
  field :hidden, type: Boolean, index: true

  links :flags, item_type: Flag

  ignore :native_sound_id       # TODO: разобраться
  ignore :secret_token
  ignore :moderator_actions

end
