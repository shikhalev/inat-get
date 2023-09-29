# frozen_string_literal: true

require_relative '../entity'
require_relative 'observation'

autoload :Project,      'inat/entity/models/project'
autoload :Place,        'inat/entity/models/place'
autoload :Taxon,        'inat/entity/models/taxon'
autoload :User,         'inat/entity/models/user'

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

  links :observations, type: List[Observation], ids_name: :observation_ids, table: :query_observations, backfield: :query_id, index: true

  class << self

    def DDL
      super +
        "\nCREATE VIEW IF NOT EXISTS project_observations AS\n" +
        "    SELECT DISTINCT q.project_id, qo.observation_id\n" +
        "           FROM queries q, query_observations qo\n" +
        "           WHERE q.id = qo.query_id AND q.project_id IS NOT NULL;"
    end

  end

end
