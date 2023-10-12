# frozen_string_literal: true

module UpdateMode

  UPDATE  = :UPDATE
  FORCE   = :FORCE
  RELOAD  = :RELOAD
  MINIMAL = :MINIMAL
  OFFLINE = :OFFLINE
  DEFAULT       = UPDATE
  FORCE_UPDATE  = FORCE
  FORCE_RELOAD  = RELOAD
  SKIP_EXISTING = MINIMAL
  NO_UPDATE     = OFFLINE

  class << self

    def parse mode
      mode = mode.to_s.gsub('-', '_').upcase.intern
      case mode
      when :UPDATE, :DEFAULT
        :UPDATE
      when :FORCE, :FORCE_UPDATE
        :FORCE
      when :RELOAD, :FORCE_RELOAD
        :RELOAD
      when :MINIMAL, :SKIP_EXISTING
        :MINIMAL
      when :OFFLINE, :NO_UPDATE
        :OFFLINE
      else
        raise TypeError, "Invalid mode: #{mode}"
      end
    end

  end

end
