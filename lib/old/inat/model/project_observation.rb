require_relative 'unique'
require_relative 'project'
require_relative 'mergeable'

class INat::Model::ProjectObservation < INat::Model::Unique
end

class INat::Model::ProjectObservation::Preferences < INat::Model
  include INat::Model::Mergeable

  field :allows_curator_coordinate_access, type: Md::Types::Bool

end

class INat::Model::ProjectObservation < INat::Model::Unique

  field :project, type: INat::Model::Project
  field :user_id, type: Integer
  field :preferences, type: INat::Model::ProjectObservation::Preferences

  field :uuid

end
