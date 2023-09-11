require_relative '../response'
require_relative '../observation'

class INat::Model::Response::Observations < INat::Model::Response

  field :results, type: Md::Types::List[INat::Model::Observation]

end
