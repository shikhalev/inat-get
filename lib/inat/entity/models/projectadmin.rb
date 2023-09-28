# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'

class ProjectAdmin < Entity

  table :project_admins

  field :role, type: Symbol, index: true, required: true
  field :project, type: Project, index: true, required: true
  field :user, type: User, index: true, required: true

end

DDL::register ProjectAdmin
