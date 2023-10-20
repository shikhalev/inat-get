# frozen_string_literal: true

Location = Struct::new :latitude, :longitude, :radius
Point    = Struct::new :latitude, :longitude
Sector   = Struct::new :ne, :sw
