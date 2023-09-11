
require_relative '../model'

class INat::Model::Project < INat::Model::Unique
end

class INat::Model::Project::RulePreference < INat::Model

  field :field, type: Symbol
  field :value

end
