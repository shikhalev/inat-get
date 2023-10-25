# frozen_string_literal: true

require 'extra/enum'

class IdentificationCategory < Enum

  items :improving,
        :supporting,
        :leading,
        :maverick

  freeze
end
