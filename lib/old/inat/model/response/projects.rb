require_relative '../response'
require_relative '../project'

class INat::Model::Response::Projects < INat::Model::Response

  field :results, type: Md::Types::List[INat::Model::Project]

end
