# frozen_string_literal: true

class List

  class Taxon

    attr_reader :taxon
    attr_reader :observations

  end

  attr_reader :source
  attr_reader :taxa

  def initialize source = nil, time: nil, normalize: (Rank::COMPLEX .. Rank::HYBRID)
    # NEED: implement
  end

  include Enumerable

  def [] taxon
    # NEED: implement
  end

  def each sort: [ :iconic, :name ]
    # NEED: implement
  end

  def to_dataset
    # NEED: implement
  end

  def include? taxon
    # NEED: implement
  end

  def where **params, &block
    # Filter content and return values as a List
    # NEED: implement
  end

  def << observation
    # NEED: implement
  end

  alias :include? :===

  def cover? other
    # NEED: implement
  end

  include Comparable

  def <=> other
    # NEED: implement
  end

  def * other
    # NEED: implement
  end

  def + other
    # NEED: implement
  end

  def - other
    # NEED: implement
  end

end
