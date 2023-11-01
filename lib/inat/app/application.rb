# frozen_string_literal: true

require_relative 'config'
require_relative 'logging'
require_relative 'preamble'
require_relative 'globals'

class Application

  include AppPreamble

  def logger
    G.logger
  end

  def initialize
    setup!
    G.config = @config.freeze
    G.logger = DualLogger::new self
  end

  def run
    preamble!
    # NEED: implement
  end

end
