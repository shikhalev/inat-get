
require_relative 'model'
require_relative 'unique'
require_relative 'controlled_value'

class INat::Model::ControlledTerm < INat::Model::Unique

  field :ontology_uri, type: URI
  field :uri, type: URI
  field :is_value, type: Md::Types::Bool
  field :multivalued, type: Md::Types::Bool
  field :taxon_ids, type: Md::Types::List[Integer]
  field :excepted_taxon_ids, type: Md::Types::List[Integer]
  field :label, type: String
  field :values, type: Md::Types::List[INat::Model::ControlledValue]

  # TODO: Types
  field :uuid

end
