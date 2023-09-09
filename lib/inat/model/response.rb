# frozen_string_literal: true

require_relative 'model'

class INat::Model::Response < INat::Model

  field :total_results, type: Integer
  field :page, type: Integer
  field :per_page, type: Integer

end
