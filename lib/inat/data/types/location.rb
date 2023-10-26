# frozen_string_literal: true

class Location

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
