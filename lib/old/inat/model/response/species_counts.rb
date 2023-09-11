require_relative '../response'
require_relative '../species_count'

class INat::Model::Response::SpeciesCounts < INat::Model::Response

  field :results, type: Md::Types::List[INat::Model::SpeciesCount]

end
