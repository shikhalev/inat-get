
require_relative '../model'
require_relative '../unique'
require_relative '../sound'

class INat::Model::Observation < INat::Model::Unique
end

class INat::Model::Observation::Sound < INat::Model::Unique

  field :sound, type: INat::Model::Sound

  # TODO: Types
  field :uuid

end
