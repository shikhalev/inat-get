
require_relative '../model'
require_relative '../unique'
require_relative '../user'

class INat::Model::Project < INat::Model::Unique
end

class INat::Model::Project::ObservationRule < INat::Model::Unique

  field :operand_id, type: Integer
  field :operand_type, type: Symbol
  field :operator, type: Symbol

end
