
require_relative './mod'
require_relative './ddl'

class ING::DBO::Model

  class << self
    include ING::DBO::DDL
  end

end
