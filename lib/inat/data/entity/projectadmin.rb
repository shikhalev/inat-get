# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'
require_relative '../enums/projectadminrole'

# require_relative 'project'
# autoload :Project, 'inat/data/entity/project'

class Project < Entity; end

class ProjectAdmin < Entity

  table :project_admins

  field :project, type: Project, index: true
  field :role, type: ProjectAdminRole, index: true, required: true
  field :user, type: User, index: true, required: true

end
