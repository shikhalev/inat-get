# frozen_string_literal: true

module Globals

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

  end

end

G = Globals

module LogDSL

  def included mod
    mod.extend LogDSL
  end

  def log message, level: MessageLevel::INFO
    G.logger.log G.current_task&.name, level, message
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
