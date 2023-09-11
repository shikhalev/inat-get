require_relative '../response'
require_relative '../place'

class INat::Model::Response::Places < INat::Model::Response

  field :results, type: Md::Types::List[INat::Model::Place]

end

class INat::Model::Response::Places::Results < INat::Model

  field :standard, type: Md::Types::List[INat::Model::Place]
  field :community, type: Md::Types::List[INat::Model::Place]

end

class INat::Model::Response::Places::NearBy < INat::Model::Response

  field :results, type: INat::Model::Response::Places::Results

end
