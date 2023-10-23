# frozen_string_literal: true

require 'extra/enum'

class GeoPrivacy < Enum

  items :open,
        :obscured,
        :obscured_private

  item_alias :private => :obscured_private

  freeze
end
