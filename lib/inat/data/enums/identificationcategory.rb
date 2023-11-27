# frozen_string_literal: true

require 'extra/enum'

class INat::Data::Types::IdentificationCategory < Enum

  items :improving,
        :supporting,
        :leading,
        :maverick

  freeze
end
