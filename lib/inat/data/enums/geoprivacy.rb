# frozen_string_literal: true

require 'extra/enum'

module INat::Data::Types; end

class INat::Data::Types::GeoPrivacy < Enum

  items :open,
        :obscured,
        :obscured_private

  item_alias :private => :obscured_private

  freeze
end
