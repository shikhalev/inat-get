# frozen_string_literal: true

require 'extra/enum'

class QualityGrade < Enum

  items :research,
        :needs_id,
        :casual

  freeze
end
