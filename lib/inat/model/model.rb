# frozen_string_literal: true

require_relative '../mod'
require 'md'

class INat::Model

  include Md;

  def initialize **props
    from! props
  end

end
