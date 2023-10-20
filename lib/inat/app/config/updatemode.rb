# frozen_string_literal: true

require 'extra/enum'

class UpdateMode < Enum

  items :UPDATE,
        :FORCE,
        :RELOAD,
        :MINIMAL,
        :OFFLINE

  item_alias :DEFAULT       => :UPDATE,
             :FORCE_UPDATE  => :FORCE,
             :FORCE_RELOAD  => :RELOAD,
             :SKIP_EXISTING => :MINIMAL,
             :NO_UPDATE     => :OFFLINE

  freeze
end
