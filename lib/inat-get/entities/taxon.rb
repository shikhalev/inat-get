
require_relative '../dbo/entity'

class Taxon < ING::DBO::Entity

  table :taxa

  register

end

# ING::DBO::DDL.register Taxon
