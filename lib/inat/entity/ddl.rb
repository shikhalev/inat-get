# frozen_string_literal: true

module DDL

  class << self

    def << mod
      @mods ||= []
      @mods << mod
    end

    def DDL
      @mods ||= []
      @mods.select { |m| m.table }.map { |m| m.DDL }.join("\n\n")
    end

    def dump
      @mods.select { |m| m.table }
    end

  end

end
