
require_relative 'model'

class INat::Model::OutLink < INat::Model
  field :source, type: Symbol
  field :url, type: String
end
