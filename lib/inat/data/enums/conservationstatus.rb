# frozen_string_literal: true

require 'extra/enum'

class CS < Enum

  item :NE, data:  0
  item :DD, data:  5
  item :LC, data: 10
  item :NT, data: 20
  item :VU, data: 30
  item :EN, data: 40
  item :CR, data: 50
  item :EW, data: 60
  item :EX, data: 70

  item_alias :not_evaluated         => :NE,
             :data_deficient        => :DD,
             :least_concern         => :LC,
             :near_threatened       => :NT,
             :vulnerable            => :VU,
             :endangered            => :EN,
             :critically_endangered => :CR,
             :extinct_in_the_wild   => :EW,
             :extinct               => :EX

  freeze
end

ConservationStatus = CS
