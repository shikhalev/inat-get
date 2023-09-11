
require_relative '../model'
require_relative '../unique'

class INat::Model::Observation < INat::Model::Unique
end

class INat::Model::Observation::Preferences < INat::Model
  field :prefers_community_taxon, type: Md::Types::Bool
end
