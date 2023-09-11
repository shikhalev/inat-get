
require_relative 'model'

class INat::Model::SearchParameter < INat::Model

  field :field, type: Symbol
  field :value_number, type: Md::Types::List[Integer]
  field :value_bool, type: Md::Types::Bool

  field :value
  field :value_keyword

end
