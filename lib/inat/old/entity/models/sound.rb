# frozen_string_literal: true

require_relative '../entity'

class Sound < Entity

  table :sounds

  field :license_code, type: Symbol, index: true
  field :attribution, type: String
  field :file_url, type: URI
  field :file_content_type, type: Symbol, index: true
  field :play_local, type: Boolean
  field :subtype, type: Symbol, index: true
  field :hidden, type: Boolean, index: true

  links :flags, type: List[Flag], ids_name: :flag_ids

  # TODO: разобраться
  field :native_sound_id, type: Wrapper
  field :secret_token, type: Wrapper
  field :moderator_actions, type: Wrapper

end
