
require_relative '../model'
require_relative '../unique'
require_relative '../mergeable'

class INat::Model::User < INat::Model::Unique
end

class INat::Model::User::Preferences < INat::Model
  include INat::Model::Mergeable
  # field :prefers_community_taxon, type: Md::Types::Bool
end
