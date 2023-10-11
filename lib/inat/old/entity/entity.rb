# frozen_string_literal: true

require_relative 'types'
require_relative 'model'

class Entity < Model

  using Types

  field :id, type: Integer, required: true, primary_key: true

end
