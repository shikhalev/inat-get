# frozen_string_literal: true

require_relative '../globals'
require_relative '../config/messagelevel'

class Task; end

module Task::DSL

  include LogDSL

  def select **params
    cache.select **params
  end

  module_function :select

end
