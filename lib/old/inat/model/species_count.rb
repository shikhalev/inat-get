
require_relative 'model'
require_relative 'taxon'

class INat::Model::SpeciesCount < INat::Model

  field :count, type: Integer
  field :taxon, type: INat::Model::Taxon

end
