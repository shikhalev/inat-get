# frozen_string_literal: true

require_relative 'config'
require_relative 'logging'

class Application

  attr_reader :logger

  def initialize
    setup!
    @logger = DualLogger::new self
  end

end
