# frozen_string_literal: true

require_relative '../config/messagelevel'

class Task; end

module Task::DSL

  def select **params
    # TODO: implement
  end

  def log message, level: MessageLevel::INFO
    logger.log name, level, message
  end

  def error message, exception: nil
    log message, level: MessageLevel::ERROR
    raise exception, message if exception
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

  module_function :select
  module_function :log, :error, :warning, :info, :debug, :echo

end
