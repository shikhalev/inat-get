# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../entity'

class INat::Entity::Project < INat::Data::Entity; end

class INat::Entity::ProjectObservationRule < INat::Data::Entity

  include INat::Entity

  table :project_observation_rules

  field :project, type: Project, index: true

  field :operator, type: Symbol, index: true, required: true
  field :operand_type, type: Symbol, index: true
  field :operand_id, type: Integer, index: true

  class << self

    def DDL
      super +
      "CREATE VIEW IF NOT EXISTS project_children AS\n" +
      "  SELECT project_id, operand_id as child_id\n" +
      "         FROM project_observation_rules\n" +
      "         WHERE operator = 'in_project?' AND operand_type = 'Project';\n" +
      "CREATE VIEW IF NOT EXISTS project_rule_taxa AS\n" +
      "  SELECT project_id, operand_id as taxon_id\n" +
      "         FROM project_observation_rules\n" +
      "         WHERE operator = 'in_taxon?' AND operand_type = 'Taxon';\n" +
      "CREATE VIEW IF NOT EXISTS project_rule_places AS\n" +
      "  SELECT project_id, operand_id as place_id\n" +
      "         FROM project_observation_rules\n" +
      "         WHERE operator = 'observed_in_place?' AND operand_type = 'Place';\n" +
      "CREATE VIEW IF NOT EXISTS project_rule_excluded_taxa AS\n" +
      "  SELECT project_id, operand_id as taxon_id\n" +
      "         FROM project_observation_rules\n" +
      "         WHERE operator = 'not_in_taxon?' AND operand_type = 'Taxon';\n" +
      "CREATE VIEW IF NOT EXISTS project_rule_excluded_places AS\n" +
      "  SELECT project_id, operand_id as place_id\n" +
      "         FROM project_observation_rules\n" +
      "         WHERE operator = 'not_observed_in_place?' AND operand_type = 'Place';\n"
    end

  end

end
