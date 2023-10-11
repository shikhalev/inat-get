# frozen_string_literal: true

require 'time'

require_relative 'db'
require_relative 'utils/values'

class Cache

  include Values

  attr_reader :config, :API, :DB

  def API
    @api
  end

  def DB
    @db
  end

  def initialize config, api
    @config = config
    @api = api
    @db_enabled = config[:data][:cache]
    @api_enabled = config[:data][:update] != :no
    if @db_enabled
      @db = DB::new @config
    end
  end

  private def is_query_in_other? query, base
    base.each do |key, value|
      qv = query[key]
      return false if qv.nil?
      if key == :d1
        db = Date::parse value
        dq = Date::parse qv
        return false if dq < db
      elsif key == :d2
        db = Date::parse value
        dq = Date::parse qv
        return false if dq > db
      # TODO: учесть вложенность таксонов когда-нибудь
      else
        if Array === value
          if Array === qv
            qv.each do |v|
              return false if !value.include?(v)
            end
          else
            return false if !value.include?(qv)
          end
        else
          return false if value != qv
        end
      end
    end
    return true
  end

  private def get_query_time query
    return nil if !@db_enabled
    query_times = @db.get_query_times
    query_times.each do |qt|
      data = Marshal.load(qt.query_data)
      return qt.query_time if is_query_in_other?(query, data)
    end
    return nil
  end

  private def get_data entities, id
    if @config[:data][:cache]
      cached = @db.execute "SELECT * FROM #{entities} WHERE id = ?;", id
      return cached.first if cached.size > 0
    end
    if @config[:data][:update] != :no
      fetched = @api.get entities, id
      return fetched.first if fetched.size > 0
    end
    raise ArgumentError, "Object not found: #{entities}/#{id}."
  end

  def get_object cls, id
    @@objects ||= {}
    @@objects[cls] ||= {}
    @@objects[cls][id] ||= cls.new self
    @@objects[cls][id]
  end

  def observation **data
    @observations ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid observation data (no ID): #{data.inspect}." if id.nil?
    if !@observations.has_key?(id)
      @observations[id] = Observation::new
      data = get_data 'observations', id if data.size == 1
    end
    @observations[id].update! **data
  end

  def identification **data
    @identifications ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid identification data (no ID): #{data.inspect}." if id.nil?
    if !@identifications.has_key?(id)
      @identifications[id] = Identification::new
      data = get_data 'identifications', id if data.size == 1
    end
    @identifications[id].update! **data
  end

  def taxon **data
    @taxa ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid taxon data (no ID): #{data.inspect}." if id.nil?
    if !@taxa.has_key?(id)
      @taxa[id] = Taxon::new
      data = get_data 'taxa', id if data.size == 1
    end
    @taxa[id].update! **data
  end

  # TODO: implement work by slug
  def project **data
    @projects ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid project data (no ID): #{data.inspect}." if id.nil?
    if !@projects.has_key?(id)
      @projects[id] = Project::new
      data = get_data 'projects', id if data.size == 1
    end
    @projects[id].update! **data
  end

  # TODO: implement work by slug
  def place **data
    @places ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid place data (no ID): #{data.inspect}." if id.nil?
    if !@places.has_key?(id)
      @places[id] = Place::new
      data = get_data 'places', id if data.size == 1
    end
    @places[id].update! **data
  end

  def user **data
    @users ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid user data (no ID): #{data.inspect}." if id.nil?
    if !@users.has_key?(id)
      @users[id] = User::new
      data = get_data 'users', id if data.size == 1
    end
    @users[id].merge! **data
  end

  # TODO: исключить запрос к серверу, там такого нет
  def photo **data
    @photos ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid photo data (no ID): #{data.inspect}." if id.nil?
    if !@photos.has_key?(id)
      @photos[id] = Photo::new
      data = get_data 'photos', id if data.size == 1
    end
    @photos[id].merge! **data
  end

  # TODO: исключить запрос к серверу, там такого нет
  def sound **data
    @sounds ||= {}
    id = data[:id] || data['id']
    raise ArgumentError, "Invalid sound data (no ID): #{data.inspect}." if id.nil?
    if !@sounds.has_key?(id)
      @sounds[id] = Sound::new
      data = get_data 'sounds', id if data.size == 1
    end
    @sounds[id].merge! **data
  end

  private def process data, save: true
    result = []
    data.each do |value|
      object = observation value
      object.save if save
      result << object
    end
    result
  end

  private def direct **query
    data = @api.select **query
    observations = process data, save: false
    DataSet::new self, observations
  end

  private def offline **query
    where = []
    args = []
    query.each do |key, value|
      # TODO: сделать условия !!!
    end
    data = @db.execute "SELECT * FROM observations WHERE #{where.join(' AND ')};", *args
    observations = process data, save: false
    DataSet::new self, observations
  end

  private def reload **query
    data = @api.select **query
    process data
    offline **query
  end

  private def update time, **query
    up_query = query.dup
    up_query[:updated_since] = Time.at(time).xmlschema
    data = @api.select **up_query
    process data
    offline **query
  end

  def select **query
    if !@config[:data][:cache]
      return direct **query
    end
    update_interval = parse_interval(@config[:data][:update_interval])
    mode = @config[:data][:update]
    case mode
    when :update
      if time
        if (Time::now.to_i - time) < update_interval
          offline **query
        else
          update time, **query
        end
      else
        reload **query
      end
    when :force
      time = get_query_time query
      update time, **query
    when :reload
      reload **query
    when :skip
      time = get_query_time query
      if time
        offline **query
      else
        reload **query
      end
    when :no
      offline **query
    end
  end

end
