# frozen_string_literal: true

module DDL

  class << self

    def register mod
      @mods ||= []
      @mods << mod
    end

    def DDL
      @mods ||= []
      inner = []
      outer = []
      after = []
      @mods.map { |m| m.DDL }.join("\n\n")
      # @mods.each do |mod|
      #   mod_ddl = mod.DDL
      #   inner << mod_ddl[0]
      #   after << mod_ddl[1]
      #   outer << mod_ddl[2]
      # end
      # [ inner.join("\n\n"), after.join("\n\n"), outer.join("\n\n") ].join("\n\n")
    end

  end

end
