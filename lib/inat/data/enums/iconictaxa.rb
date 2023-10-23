# frozen_string_literal: true

require 'extra/enum'

class IconicTaxa < Enum

  items :Aves,
        :Amphibia,
        :Reptilia,
        :Mammalia,
        :Actinopterygii,
        :Mollusca,
        :Arachnida,
        :Insecta,
        :Animalia,
        :Plantae,
        :Fungi,
        :Protozoa,
        :Chromista,
        :unknown

  freeze
end
