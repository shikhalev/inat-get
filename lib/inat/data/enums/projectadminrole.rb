# frozen_string_literal: true

require 'extra/enum'

class ProjectAdminRole < Enum

  items :curator,
        :manager

  freeze
end
