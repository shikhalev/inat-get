# frozen_string_literal: true

require_relative 'config'
require_relative 'logging'
require_relative 'preamble'
require_relative '../cache/cache'
require_relative 'globals'

class Application

  include AppPreamble

  attr_reader :logger

  def logger
    G.logger
  end

  def initialize
    setup!
    G.logger = DualLogger::new self
    @cache = Cache::new self
  end

  def run
    preamble!
    # NEED: implement
  end

end
