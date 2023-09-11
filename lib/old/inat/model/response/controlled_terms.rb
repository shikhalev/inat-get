require_relative '../response'
require_relative '../controlled_term'

class INat::Model::Response::ControlledTerms < INat::Model::Response

  field :results, type: Md::Types::List[INat::Model::ControlledTerm]

end
