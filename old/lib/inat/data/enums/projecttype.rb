# frozen_string_literal: true

require 'extra/enum'

# TODO: подумать над занесением внутрь Project

class INat::Data::Types::ProjectType < Enum

  items :collection,
        :umbrella,
        :contest,
        :bioblitz,
        :assessment,
        :manual

  # TODO: переделать тип во что-то универсальное. наверное.

  class << self

    def parse src
      if src == ''
        return MANUAL
      else
        super src
      end
    end

  end

  def to_s
    if self == MANUAL
      return ''
    else
      super
    end
  end

  freeze
end
