
require_relative '../model'
require_relative '../unique'
require_relative '../photo'

class INat::Model::Observation < INat::Model::Unique
end

class INat::Model::Observation::Photo < INat::Model::Unique

  field :position, type: Integer
  field :photo_id, type: Integer
  field :photo, type: INat::Model::Photo

  # TODO: Types
  field :uuid

end
