# frozen_string_literal: true

require_relative 'logging'
require_relative 'config'

module INat
  module App
  end
end

module INat::App::Globals

  class << self

    def logger
      @@logger
    end

    def logger= value
      @@logger = value
    end

    def current_task
      Thread.current.thread_variable_get 'current_task'
    end

    def current_task= value
      Thread.current.thread_variable_set 'current_task', value
    end

    def config
      @@config
    end

    def config= value
      @@config = value
    end

    def status
      @@status
    end

    def status= value
      @@status = value
    end

  end

end

G = INat::App::Globals

module INat::App::Logger::DSL

  include INat::App::Config

  # @private
  def included mod
    mod.extend LogDSL
  end

  def log message, level: MessageLevel::INFO
    G.status.wrap do
      G.logger.log(G.current_task&.name || '‹main›', level, message)
    end
  end

  def error message, exception: nil
    log message, level: MessageLevel::ERROR
    raise exception, message if Class === exception && Exception >= exception
  end

  def warning message
    log message, level: MessageLevel::WARNING
  end

  def info message
    log message, level: MessageLevel::INFO
  end

  def debug message
    log message, level: MessageLevel::DEBUG
  end

  def echo message, level: MessageLevel::UNKNOWN
    log message, level: level
  end

  module_function :log, :error, :warning, :info, :debug, :echo

end
