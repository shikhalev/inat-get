
require_relative 'model'
require_relative 'mergeable'

class INat::Model::DateDetails < INat::Model
  include INat::Model::Mergeable

  field :date, type: Date
  field :week, type: Integer
  field :year, type: Integer
  field :month, type: Integer
  field :day, type: Integer
  field :hour, type: Integer
end
