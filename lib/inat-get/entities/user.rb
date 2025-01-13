
require_relative '../dbo/entity'

class User < ING::DBO::Entity

  table :users

  field :login, type: Symbol, unique: true

  register

end

# ING::DBO::DDL.register User
