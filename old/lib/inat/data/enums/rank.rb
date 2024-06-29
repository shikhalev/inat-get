# frozen_string_literal: true

require 'extra/enum'

class INat::Data::Types::Rank < Enum

  item :stateofmatter, data: 100
  item :kingdom,       data:  70
  item :phylum,        data:  60
  item :subphylum,     data:  57
  item :superclass,    data:  53
  item :class,         data:  50
  item :subclass,      data:  47
  item :infraclass,    data:  45
  item :subterclass,   data:  44
  item :superorder,    data:  43
  item :order,         data:  40
  item :suborder,      data:  37
  item :infraorder,    data:  35
  item :parvorder,     data:  34.5
  item :zoosection,    data:  34
  item :zoosubsection, data:  33.5
  item :superfamily,   data:  33
  item :epifamily,     data:  32
  item :family,        data:  30
  item :subfamily,     data:  27
  item :supertribe,    data:  26
  item :tribe,         data:  25
  item :subtribe,      data:  24
  item :genus,         data:  20
  item :genushybrid,   data:  20
  item :subgenus,      data:  15
  item :section,       data:  13
  item :subsection,    data:  12
  item :complex,       data:  11
  item :species,       data:  10
  item :hybrid,        data:  10
  item :subspecies,    data:   5
  item :variety,       data:   5
  item :form,          data:   5
  item :infrahybrid,   data:   5

  item_alias :division       => :phylum,
             :'sub-class'    => :subclass,
             :'super-order'  => :superorder,
             :'sub-order'    => :suborder,
             :'super-family' => :superfamily,
             :'sub-family'   => :subfamily,
             :gen            => :genus,
             :sp             => :species,
             :spp            => :species,
             :infraspecies   => :subspecies,
             :ssp            => :subspecies,
             :'sub-species'  => :subspecies,
             :subsp          => :subspecies,
             :trinomial      => :subspecies,
             :var            => :variety

  freeze
end
