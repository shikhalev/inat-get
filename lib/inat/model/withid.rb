# frozen_string_literal: true

require_relative 'model'

class WithId

  include Model

  field :id, type: Integer, primary_key: true

end
