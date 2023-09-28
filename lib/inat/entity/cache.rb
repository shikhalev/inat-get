# frozen_string_literal: true

class EntityCache

  include Enumerable

  attr_reader :root, :type, :API, :DB

  def API
    @root.API
  end

  def DB
    @root.DB
  end

  def config
    @root.config
  end

  def initialize root, type
    @root = root
    @type = type
    @objects = {}
  end

  def [] id
    raise TypeError, "'id' parameter is not a valid Integer: #{id.inspect}!" unless Integer === id
    if !@objects.has_key?(id)
      @objects[id] = @type.new @root
      if @config[:data][:cache]
        data = DB.execute("SELECT * FROM #{@type.table} WHERE id = ?", id).first || { id: id }
        links = @type.fields.select { |_, info| info[:kind] == :links && Symbol === info[:ids_name] && !info[:readonly] }
        links.each do |_, info|
          linkdata = DB.execute "SELECT * FROM #{info[:table]} WHERE #{info[:backfield]} = ?", id
          data[info[:ids_name]] = linkdata.map { |item| item[info[:linkfield].to_s] }                     # TODO: проверить, что именно .to_s
        end
        backs = @type.fields.select { |_, info| info[:kind] == :backs && !info[:readonly] }
        backs.each do |_, info|
          item_class = info[:type].item_class
          backdata = DB.execute "SELECT * FROM #{item_class.table} WHERE #{info[:backfield]} = ?", id
          data[info[:name]] = backdata.map { |item| item_class.make(item, @root, from: :DB) }
        end
        @objects[id].apply! from: :DB, **data
      end
    end
    @objects[id]
  end

  def get *ids
    raise ArgumentError, "At least one argument must be provided!" if ids.empty?
    if ids.size == 1
      self[ids.first]
    else
      ids.map { |id| self[id] }
    end
  end

  def make from: :API, **data
    id = data[:id] || data['id']
    raise ArgumentError, "At least 'id' parameter must be provided!" if id.nil?
    self[id].apply! from: from, **data
  end

  def fetch *ids
    raise ArgumentError, "At least one argument must be provided!" if ids.empty?
    data = API.get @type.path, *ids
    if ids.size == 1
      hash = data.first
      self[hash[:id] || hash['id']].apply!(from: :API, hash)
    else
      data.map { |hash| self[hash[:id] || hash['id']].apply!(from: API, hash) }
    end
  end

  def find fetch: false, **query
    each(fetch: fetch, **query).first
  end

  def each fetch: false, **query
    if block_given?
      @objects.each do |id, obj|
        if obj.matches?(**query)
          obj = self.fetch(id) if fetch
          yield obj
        end
      end
    else
      to_enum __method__, fetch: fetch, **query
    end
  end

end


class EntitiesCache

  include Enumerable

  attr_reader :cache
  attr_reader :API, :DB

  def API
    @cache.API
  end

  def DB
    @cache.DB
  end

  def config
    @cache.config
  end

  def initialize cache
    @cache = cache
  end

  def [] type
    raise TypeError, "Parameter is not a valid entity class: #{type.inspect}" unless Class === type && Entity > type
    @classes ||= {}
    @classes[type] ||= EntityCache::new self, type
    @classes[type]
  end

  def each
    if block_given?
      @classes.each_value do |item|
        yield item
      end
    else
      to_enum __method__
    end
  end

  def observations
    self[Observation]
  end

  def taxa
    self[Taxon]
  end

  def users
    self[User]
  end

  def projects
    self[Project]
  end

  def places
    self[Place]
  end

end
