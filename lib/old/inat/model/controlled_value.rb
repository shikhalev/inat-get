
require_relative 'model'
require_relative 'unique'
require_relative 'controlled_label'

class INat::Model::ControlledValue < INat::Model::Unique

  field :is_value, type: Md::Types::Bool
  field :ontology_uri, type: URI
  field :uri, type: URI
  field :taxon_ids, type: Md::Types::List[Integer]
  field :excepted_taxon_ids, type: Md::Types::List[Integer]
  field :label, type: String
  field :blocking, type: Md::Types::Bool
  field :labels, type: Md::Types::List[INat::Model::ControlledLabel]

  # TODO: Types
  field :uuid

end
