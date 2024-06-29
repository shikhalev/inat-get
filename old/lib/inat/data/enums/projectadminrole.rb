# frozen_string_literal: true

require 'extra/enum'

class INat::Data::Types::ProjectAdminRole < Enum

  items :curator,
        :manager

  freeze
end
