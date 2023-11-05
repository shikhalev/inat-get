# frozen_string_literal: true

require 'extra/enum'

class ProjectType < Enum

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
        return ProjectType::MANUAL
      else
        super src
      end
    end

  end

  def to_s
    if self == ProjectType::MANUAL
      return ''
    else
      super
    end
  end

  freeze
end
