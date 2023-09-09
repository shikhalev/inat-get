
require_relative '../model'
require_relative '../unique'

class INat::Model::User < INat::Model::Unique
end

class INat::Model::User::Preferences < INat::Model
  # field :prefers_community_taxon, type: Md::Types::Bool
end
