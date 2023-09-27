# frozen_string_literal: true

class Location

  class << self

    def make data, cache: nil, from: :API
      self.new data
    end

    def db_type
      :TEXT
    end

  end

  attr_reader :latitude, :longitude, :pair

  def initialize src
    @latitude, @longitude = src.split(',').map { |l| l.to_f }
  end

  def pair
    [ @latitude, @longitude ]
  end

  def to_s
    "#{@latitude},#{@longitude}"
  end

  def to_db
    to_s
  end

end
