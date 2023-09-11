
require_relative 'model'
require_relative 'unique'
require_relative 'user'
require_relative 'project/admin'
require_relative 'project/observation_rule'
require_relative 'project/rule_preference'
require_relative 'flag'
require_relative 'search_parameter'

class INat::Model::Project < INat::Model::Unique

  field :icon, type: URI
  field :description, type: String
  field :created_at, type: Time
  field :title, type: String
  field :observation_requirements_updated_at, type: Time
  field :updated_at, type: Time
  field :prefers_user_trust, type: Md::Types::Bool
  field :slug, type: String
  field :place_id, type: Integer
  field :icon_file_name, type: String
  field :project_type, type: Symbol
  field :user_ids, type: Md::Types::List[Integer]
  field :header_image_file_name, type: String
  field :user_id, type: Integer
  field :hide_title, type: Md::Types::Bool
  field :header_image_contain, type: Md::Types::Bool
  field :header_image_url, type: URI
  field :is_umbrella, type: Md::Types::Bool
  field :hide_umbrella_map_flags, type: Md::Types::Bool
  field :banner_color, type: String
  field :user, type: INat::Model::User
  field :admins, type: Md::Types::List[INat::Model::Project::Admin]
  field :flags, type: Md::Types::List[INat::Model::Flag]
  field :project_observation_rules, type: Md::Types::List[INat::Model::Project::ObservationRule]
  field :search_parameters, type: Md::Types::List[INat::Model::SearchParameter]
  field :rule_preferences, type: Md::Types::List[INat::Model::Project::RulePreference]

  # TODO: Types
  field :site_features
  field :project_observation_fields
  field :terms
  field :location

end
