# frozen_string_literal: true

require_relative '../entity'

autoload :ProjectAdmin, 'inat/entity/models/projectadmin'

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

  links :flags, type: List[Flag], ids_name: :flag_ids

  links :observations, type: List[Observation], ids_name: :observation_ids, table: :project_observations, backfield: :project_id, linkfield: :observation_id,
                       own: false, readonly: true

  # TODO: разобраться и сделать связи с местами и таксонами
  field :project_observation_rules, type: Wrapper
  field :project_observation_fields, type: Wrapper
  field :site_features, type: Wrapper
  field :terms, type: Wrapper
  field :search_parameters, type: Wrapper
  field :rule_preferences, type: Wrapper

end
