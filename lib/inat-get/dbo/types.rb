
require "time"
require "date"
require "uri"
require_relative '../../extra/uuid'
require_relative '../../extra/location'
require_relative './ddl'

class Integer

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :BIGINT }
    end

  end

end

class Symbol

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :'VARCHAR(64)' }
    end

  end

end

class UUID

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :UUID }
    end

  end

end

class Time

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :'TIMESTAMP WITH TIME ZONE' }
    end

  end

end

class Date

  class << self

    include ING::DBO::Type

    def DDL name
      {  "#{ name }" => :DATE }
    end

  end

end

class Text

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :TEXT }
    end

  end

end

module Boolean

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :BOOLEAN }
    end

  end

end

class TrueClass
  include Boolean
end
class FalseClass
  include Boolean
end

module URI

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }" => :'VARCHAR(1024)' }
    end

  end

end

class Location

  class << self

    include ING::DBO::Type

    def DDL name
      { "#{ name }_latitude" => :'NUMERIC(9,6)',
        "#{ name }_longitude" => :'NUMERIC(9,6)' }
    end

  end

end
