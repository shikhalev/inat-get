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
        new(src[:latitude] || src['latitude'], src[:longitude] || src['longitude']).freeze
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
    raise ArgumentError, "Latitude must be a Numeric!", caller  unless Numeric === latitude
    raise ArgumentError, "Longitude must be a Numeric!", caller unless Numeric === longitude
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
