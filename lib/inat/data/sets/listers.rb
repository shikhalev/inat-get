# frozen_string_literal: true

require_relative 'wrappers'

module Listers

  SPECIES = lambda { |o| o.normalized_taxon(Rank::COMPLEX .. Rank::HYBRID)  }
  GENUS   = lambda { |o| o.normalized_taxon(Rank::GENUS)                    }
  FAMILY  = lambda { |o| o.normalized_taxon(Rank::FAMILY)                   }
  YEAR    = lambda { |o| Year[o.observed_on]                                }
  MONTH   = lambda { |o| Month[o.observed_on]                               }
  DAY     = lambda { |o| Day[o.observed_on]                                 }
  USER    = lambda { |o| o.user                                             }

end
