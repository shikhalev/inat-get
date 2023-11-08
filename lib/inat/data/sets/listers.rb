# frozen_string_literal: true

module Listers

  SPECIES = lambda { |o| o.normalized_taxon(Rank::COMPLEX .. Rank::HYBRID)  }
  GENUS   = lambda { |o| o.normalized_taxon(Rank::GENUS)                    }
  FAMILY  = lambda { |o| o.normalized_taxon(Rank::FAMILY)                   }
  YEAR    = lambda { |o| o.year                                             }
  MONTH   = lambda { |o| o.month                                            }
  DAY     = lambda { |o| o.day                                              }
  USER    = lambda { |o| o.user                                             }

end
