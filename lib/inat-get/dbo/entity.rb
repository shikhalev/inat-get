
require_relative './ddl'
require_relative './model'
require_relative './types'

class ING::DBO::Entity < ING::DBO::Model

  field :id, type: Integer, primary_key: true

end
