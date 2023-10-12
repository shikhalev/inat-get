# frozen_string_literal: true

require 'logger'

module MessageLevel

  UNKNOWN = :UNKNOWN
  FATAL   = :FATAL
  ERROR   = :ERROR
  WARNING = :WARNING
  INFO    = :INFO
  DEBUG   = :DEBUG
  WARN = WARNING

  class << self

    def parse level
      lvl = level.to_s.upcase.intern
      case lvl
      when :INFO, :DEBUG, :WARNING, :ERROR, :FATAL, :UNKNOWN
        lvl
      when :WARN
        :WARNING
      else
        raise TypeError, "Unknown message level: #{level.inspect}!"
      end
    end

    def severity level
      case parse(level)
      when MessageLevel::UNKNOWN
        Logger::Severity::UNKNOWN
      when MessageLevel::FATAL
        Logger::Severity::FATAL
      when MessageLevel::ERROR
        Logger::Severity::ERROR
      when MessageLevel::WARNING
        Logger::Severity::WARN
      when MessageLevel::INFO
        Logger::Severity::INFO
      when MessageLevel::DEBUG
        Logger::Severity::DEBUG
      else
        raise ArgumentError, "Unknown message level: #{level.inspect}!"
      end
    end

  end

end
