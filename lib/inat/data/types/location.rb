# frozen_string_literal: true

module INat::Data; end
module INat::Data::Types; end

class INat::Data::Types::Location

  class << self

    def parse src
      case src
      when nil
        nil
      when String
        parse src.split(',').map(&:to_f)
      when Array
        new(src[0], src[1]).freeze
      when Hash
        latitude = src[:latitude] || src['latitude']
        longitude = src[:longitude] || src['longitude']
        return nil if latitude == nil && longitude == nil
        new(latitude, longitude).freeze
      else
        raise ArgumentError, "Source must be a String or Array or Hash!", caller
      end
    end

    def from_db src
      new(src[:latitude] || src['latitude'], src[:longitude] || src['longitude']).freeze
    end

    def ddl
      {
        latitude: :REAL,
        longitude: :REAL
      }
    end

  end

  attr_reader :latitude, :longitude

  def initialize latitude, longitude
    raise ArgumentError, "Latitude must be a Numeric!", caller  unless Numeric === latitude  || latitude == nil
    raise ArgumentError, "Longitude must be a Numeric!", caller unless Numeric === longitude || latitude == nil
    @latitude = latitude
    @longitude = longitude
  end

  def to_db
    {
      latitude: latitude,
      longitude: longitude
    }
  end

end

class INat::Data::Types::Radius

  attr_reader :latitude, :longitude, :radius

  def initialize latitude, longitude, radius
    raise ArgumentError, "Latitude must be a Numeric!", caller  unless Numeric === latitude
    raise ArgumentError, "Longitude must be a Numeric!", caller unless Numeric === longitude
    raise ArgumentError, "Radius must be a Numeric!", caller    unless Numeric === radius    || radius == nil
    @latitude, @longitude, @radius = latitude, longitude, radius
  end

end

class INat::Data::Types::Sector

  attr_reader :north, :east, :south, :west

  def initialize north, east, south, west
    raise ArgumentError, "North must be a Numeric!", caller unless Numeric === north
    raise ArgumentError, "East must be a Numeric!", caller  unless Numeric === east
    raise ArgumentError, "South must be a Numeric!", caller unless Numeric === south
    raise ArgumentError, "West must be a Numeric!", caller  unless Numeric === west
    @north, @east, @south, @west = north, east, south, west
  end

end

module INat::Data::Types

  def radius latitude, longitude, radius
    Radius::new latitude, longitude, radius
  end

  def sector north, east, south, west
    Sector::new north, east, south, west
  end

  module_function :radius, :sector

end
