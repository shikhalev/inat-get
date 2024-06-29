# frozen_string_literal: true

require_relative 'wrappers'

# TODO: возможно, загнать внутрь List?

module INat::Report::Listers

  include INat::Report
  include INat::Data::Types

  SPECIES = lambda { |o| o.normalized_taxon(Rank::COMPLEX .. Rank::HYBRID)  }
  GENUS   = lambda { |o| o.normalized_taxon(Rank::GENUS)                    }
  FAMILY  = lambda { |o| o.normalized_taxon(Rank::FAMILY)                   }
  YEAR    = lambda { |o| Period::Year[o.observed_on]                        }
  MONTH   = lambda { |o| Period::Month[o.observed_on]                       }
  DAY     = lambda { |o| Period::Day[o.observed_on]                         }
  WINTER  = lambda { |o| Period::Winter[o.observed_on]                      }
  USER    = lambda { |o| o.user                                             }

end
