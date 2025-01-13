
class Lication

  attr_reader :latitude, :longitude

  def initialize latitude, longitude
    raise ArgumentError, "Latitude must be a Numeric!", caller  unless Numeric === latitude  || latitude == nil
    raise ArgumentError, "Longitude must be a Numeric!", caller unless Numeric === longitude || latitude == nil
    @latitude = latitude
    @longitude = longitude
  end

end
