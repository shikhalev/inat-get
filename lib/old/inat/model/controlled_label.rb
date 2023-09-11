
require_relative 'model'
require_relative 'unique'

class INat::Model::ControlledLabel < INat::Model::Unique

  field :locale, type: Symbol
  field :label, type: String
  field :definition, type: String

  # TODO: Types
  field :valid_within_clade

end
