# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'
require_relative '../enums/projectadminrole'

class INat::Entity::Project < INat::Data::Entity; end

class INat::Entity::ProjectAdmin < INat::Data::Entity

  include INat::Data::Types
  include INat::Entity

  table :project_admins

  field :project, type: Project, index: true
  field :role, type: ProjectAdminRole, index: true, required: true
  field :user, type: User, index: true, required: true

end
