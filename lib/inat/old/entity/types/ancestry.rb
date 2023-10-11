# frozen_string_literal: true

class Ancestry

  class << self

    def make data, cache: nil, from: :API
      self.new data, cache
    end

    def db_type
      :TEXT
    end

  end

  def initialize src, cache
    @src = src
    @cache = cache
    if @src.index(',')
      @delimiter = ','
    else
      @delimiter = '/'
    end
  end

  def ancestor_ids
    @src.split(@delimiter).map { |i| i.to_i }
  end

  def ancestors
    ancestor_ids.map { |id| @cache[Taxon][id] }
  end

  def to_s
    @src
  end

  def to_db
    @src
  end

end
