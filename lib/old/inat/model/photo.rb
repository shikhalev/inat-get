
require_relative 'model'
require_relative 'unique'

class INat::Model::Photo < INat::Model::Unique

  field :license_code, type: Symbol
  field :url, type: URI
  field :attribution, type: String
  field :hidden, type: Md::Types::Bool
  field :square_url, type: URI
  field :medium_url, type: URI

  # TODO: Types
  field :original_dimensions
  field :flags
  field :moderator_actions

end
