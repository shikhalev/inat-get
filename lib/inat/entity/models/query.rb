# frozen_string_literal: true

require_relative '../ddl'
require_relative '../entity'
require_relative '../types/wrapper'
# require_relative 'observation'
# require_relative 'project'
# require_relative 'place'
# require_relative 'taxon'
# require_relative 'user'

autoload :Observation, 'inat/entity/models/observation'
autoload :Project, 'inat/entity/models/project'
autoload :Place, 'inat/entity/models/place'
autoload :Taxon, 'inat/entity/models/taxon'
autoload :User, 'inat/entity/models/user'

class DataQuery < Entity

  table :queries

  field :time, type: Time, index: true
  field :query_path, type: Symbol, index: true
  field :query_params, type: Wrapper
  field :query_url, type: URI
  field :project, type: Project, index: true
  field :place, type: Place, index: true
  field :taxon, type: Taxon, index: true
  field :user, type: User, index: true

  links :observations, type: List[Observation], ids_name: :observation_ids, table: :query_observations, index: true

  class << self

    def DDL
      super +
        "\nCREATE VIEW IF NOT EXISTS project_observations AS SELECT DISTINCT q.project_id, qo.observation_id FROM queries q, query_observations qo WHERE q.id = qo.dataset_id AND q.project_id IS NOT NULL;"
    end

  end

end

DDL::register DataQuery
