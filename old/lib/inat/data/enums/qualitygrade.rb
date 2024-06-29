# frozen_string_literal: true

require 'extra/enum'

class INat::Data::Types::QualityGrade < Enum

  items :research,
        :needs_id,
        :casual

  freeze
end
