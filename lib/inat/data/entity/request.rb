# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'
require_relative '../db'

class INat::Entity
  autoload :Observation, 'inat/data/entity/observation'
  autoload :Project,     'inat/data/entity/project'
end

class INat::Entity::Request < INat::Entity

  table :requests

  field :time, type: Time, index: true
  field :query, type: String, unique: true

  field :project, type: Project, index: true

  links :observations, item_type: Observation, index: true

  class << self

    def DDL
      super +
      "CREATE VIEW IF NOT EXISTS project_observations AS\n" +
      "  SELECT r.project_id, ro.observation_id\n" +
      "         FROM requests r, request_observations ro\n" +
      "         WHERE r.id = ro.request_id AND r.project_id IS NOT NULL;\n"
    end

    def create query_string, project_id
      update do
        max_id = DB.execute("SELECT max(id) AS id FROM requests;").map{ |r| r['id'] }.first
        new_id = if max_id == nil
          1
        else
          max_id + 1
        end
          @entities ||= {}
        @entities[new_id] ||= new new_id
        @entities[new_id].time = Time::at(0)
        @entities[new_id].query = query_string
        @entities[new_id].project_id = project_id
        @entities[new_id].save
      end
    end

  end

  attr_accessor :active

  def initialize id
    super(id)
    @active = false
  end

end
