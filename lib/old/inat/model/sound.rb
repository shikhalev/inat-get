
require_relative 'model'
require_relative 'unique'

class INat::Model::Sound < INat::Model::Unique

  field :file_url, type: URI
  field :play_local, type: Md::Types::Bool
  field :native_sound_id, type: Integer
  field :license_code, type: Symbol
  field :attribution, type: String
  field :file_content_type, type: Symbol
  field :hidden, type: Md::Types::Bool

  # TODO: Types
  field :subtype
  field :flags
  field :secret_token
  field :moderator_actions

end
