
require_relative '../model'
require_relative '../unique'
require_relative '../user'

class INat::Model::Project < INat::Model::Unique
end

class INat::Model::Project::Admin < INat::Model::Unique

  field :role, type: Symbol
  field :user_id, type: Integer
  field :project_id, type: Integer
  field :user, type: INat::Model::User

end
