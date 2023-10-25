# frozen_string_literal: true

require_relative '../types/std'
require_relative '../types/extras'
require_relative '../types/location'
require_relative '../entity'
require_relative '../enums/projecttype'

# require_relative 'projectadmin'
# require_relative 'projectobservationrule'

autoload :Observation,            'inat/data/entity/observation'
autoload :User,                   'inat/data/entity/user'
autoload :Place,                  'inat/data/entity/place'
autoload :ProjectAdmin,           'inat/data/entity/projectadmin'
autoload :ProjectObservationRule, 'inat/data/entity/projectobservationrule'
autoload :Flag,                   'inat/data/entity/flag'
autoload :Taxon,                  'inat/data/entity/taxon'

class Project < Entity

  path :projects
  table :projects

  field :slug, type: Symbol, index: true
  field :title, type: String, index: true, required: true
  field :description, type: String
  field :project_type, type: ProjectType, index: true, required: true
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
  links :users, item_type: User
  backs :admins, item_type: ProjectAdmin, owned: true
  backs :project_observation_rules, item_type: ProjectObservationRule, owned: true

  links :flags, item_type: Flag, index: true

  # NEED: implement
  # links :observations, type: List[Observation], ids_name: :observation_ids, table: :project_observations,
  #                     backfield: :project_id, linkfield: :observation_id, own: false

  links :subprojects, item_type: Project, table_name: :project_children, link_field: :child_id, owned: false

  links :included_taxa, item_type: Taxon, ids_field: :included_taxon_ids, table_name: :project_rule_taxa, owned: false
  links :excluded_taxa, item_type: Taxon, ids_field: :excluded_taxon_ids, table_name: :project_rule_excluded_taxa, owned: false
  links :included_places, item_type: Place, ids_field: :included_place_ids, table_name: :project_rule_places, owned: false
  links :excluded_places, item_type: Place, ids_field: :excluded_places_ids, table_name: :project_rule_excluded_places, owned: false

  # # TODO: разобраться и сделать связи с местами и таксонами
  # field :project_observation_fields, type: Wrapper
  # field :site_features, type: Wrapper
  # field :terms, type: Wrapper
  # field :search_parameters, type: Wrapper
  # field :rule_preferences, type: Wrapper


end
