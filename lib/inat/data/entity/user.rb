# frozen_string_literal: true

require_relative "../types/std"
require_relative "../types/extras"
require_relative "../entity"

module INat::Entity
  autoload :Observation, "inat/data/entity/observation"
end

class INat::Entity::User < INat::Data::Entity
  include INat::Entity

  api_path :users
  api_part :path
  api_limit 1

  table :users

  field :login, type: String, index: true, required: true
  field :spam, type: Boolean
  field :suspended, type: Boolean, index: true
  field :created_at, type: Time, index: true
  field :site_id, type: Integer, index: true
  field :login_autocomplete, type: String
  field :login_exact, type: String
  field :name, type: String, index: true
  field :name_autocomplete, type: String
  field :orcid, type: URI
  field :icon, type: URI
  field :icon_url, type: URI
  field :observations_count, type: Integer
  field :identifications_count, type: Integer
  field :journal_posts_count, type: Integer
  field :activity_count, type: Integer
  field :species_count, type: Integer
  field :universal_search_rank, type: Integer

  ignore :roles                   # TODO: разобраться
  ignore :preferences
  ignore :annotated_observations_count

  def sort_key
    login
  end

  def self.by_login(login)
    @entities ||= {}
    results = @entities.values.select { |e| e.login == login.to_s }
    if results.empty?
      data = DB.execute "SELECT * FROM users WHERE login = ?", login.to_s
      results = from_db_rows data
    end
    if results.empty?
      data = INat::API.query "users/autocomplete", first_only: true, q: login
      results = data.select { |u| u["login"] == login.to_s }.map { |d| parse(d) }
    end
    if results.empty?
      nil
    else
      results.first
    end
  end

  def to_s
    title = ""
    title = " title=\"#{name}\"" if name
    "<a#{title} href=\"https://www.inaturalist.org/people/#{id}\"><i class=\"glyphicon glyphicon-user\"></i></a> @#{login}"
  end
end
