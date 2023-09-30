# frozen_string_literal: true

require_relative '../entity'

autoload :ProjectAdmin,           'inat/entity/models/projectadmin'
autoload :ProjectObservationRule, 'inat/entity/models/projectobservationrule'

class Project < Entity

  path :projects
  table :projects

  field :slug, type: Symbol, index: true
  field :title, type: String, index: true, required: true
  field :description, type: String
  field :project_type, type: Symbol, index: true, required: true
  field :is_umbrella, type: Boolean, index: true
  field :created_at, type: Time
  field :updated_at, type: Time
  field :observation_requirements_updated_at, type: Time
  field :prefers_user_trust, type: Boolean
  field :icon, type: URI
  field :icon_file_name, type: String
  field :header_image_url, type: URI
  field :header_image_file_name, type: String
  field :header_image_contain, type: Boolean
  field :banner_color, type: String                                 # TODO: сделать тип
  field :hide_title, type: Boolean
  field :user, type: User, index: true
  field :location, type: Location

  field :place, type: Place, index: true
  links :users, type: List[User], ids_name: :user_ids
  backs :admins, type: List[ProjectAdmin], ids_name: :admin_ids, backfield: :project_id, own: true
  backs :project_observation_rules, type: List[ProjectObservationRule], ids_name: :project_observation_rule_ids, backfield: :project_id, own: true

  links :flags, type: List[Flag], ids_name: :flag_ids

  links :observations, type: List[Observation], ids_name: :observation_ids, table: :project_observations, backfield: :project_id, linkfield: :observation_id,
                       own: false, readonly: true

  links :subprojects, type: List[Project], ids_name: :subprojects_ids, table: :project_children, backfield: :project_id, linkfield: :child_id, own: false, readonly: true
  links :included_taxa, type: List[Taxon], ids_name: :included_taxon_ids, table: :project_rule_taxa,
                      backfield: :project_id, linkfield: :taxon_id, own: false, readonly: true
  links :excluded_taxa, type: List[Taxon], ids_name: :excluded_taxon_ids, table: :project_rule_excluded_taxa,
                      backfield: :project_id, linkfield: :taxon_id, own: false, readonly: true
  links :included_places, type: List[Place], ids_name: :included_place_ids, table: :project_rule_places,
                      backfield: :project_id, linkfield: :place_id, own: false, readonly: true
  links :excluded_places, type: List[Place], ids_name: :excluded_places_ids, table: :project_rule_excluded_places,
                      backfield: :project_id, linkfield: :place_id, own: false, readonly: true

  # TODO: разобраться и сделать связи с местами и таксонами
  field :project_observation_fields, type: Wrapper
  field :site_features, type: Wrapper
  field :terms, type: Wrapper
  field :search_parameters, type: Wrapper
  field :rule_preferences, type: Wrapper

end
