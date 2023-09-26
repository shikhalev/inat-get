# frozen_string_literal: true

# structure forward declaration
module Entity
  module Ext
  end
end

module Entity

  extend Entity::Ext

  def included mod
    mod.extend Entity::Ext
  end

  attr_reader :cache, :DB

  def DB
    @cache.DB
  end

  def matches? **query
    # TODO: implement
  end

  def apply! from: :API, **data
    fields = self.class.fields.select { |_, info| !info[:readonly] }
    data.each do |key, value|
      if fields.has_key?(key)
        self.send "#{key}=", fields[key][:type].make(value, cache: @cache, from: from)
      else
        # TODO: warning
      end
    end
    @fetched = (from == :API)
    @stored = (from == :DB)
    self
  end

  def save
    return self if @stored || !@config[:data][:cache]
    fields = self.class.fields.select { |_, info| info[:kind] == :field }
    names = []
    values = []
    fields.each do |key, info|
      if Entity > info[:type]
        names << info[:id_name]
        value = self.send key
        values << value&.id
        value.save if value
      else
        names << key
        values << self.send(key).to_db
      end
    end
    DB.execute "INSERT OR REPLACE INTO #{ self.class.table } (#{ names.join(',') }) VALUES (#{ (['?'] * names.size).join(',') });", *values
    @stored = true
    links = self.class.fields.select { |_, info| info[:kind] == :links && info[:own] }
    links.each do |key, info|
      items = self.send(key)
      items.each(&:save)
      DB.execute "DELETE FROM #{ info[:table] } WHERE #{ info[:backfield] } = ?", @id
      items.each do |item|
        DB.execute "INSERT OR REPLACE INTO #{ info[:table] } (#{ info[:backfield] }, #{ info[:linkfield] }) VALUES (?, ?)", @id, item.id
      end
    end
    backs = self.class.fields.select { |_, info| info[:kind] == :backs && info[:own] }
    backs.each do |key, info|
      items = self.send(key)
      items.each(&:save)
    end
    self
  end

  def incomplete?
    fields = self.class.fields.select { |key, info| info[:required] && key != :id }
    fields.each do |key, info|
      return true if instance_variable_get("@#{key}").nil?
    end
    false
  end

  attr_reader :fetched?, :stored?

  def fetched?
    @fetched || false
  end

  def stored?
    @stored || false
  end

  field :id, type: Integer, required: true, primary_key: true

end

module Entity::Ext

  attr_accessor :path

  def path value = nil
    @path = value if value
    @path
  end

  attr_accessor :table

  def table value = nil
    @table = value if value
    @table
  end

  attr_accessor :fields

  def field name, id_name: nil, type: nil, required: false, index: nil, unique: nil, primary_key: nil
    # TODO: implement
  end

  #
  # Связь многие-ко-многим
  #
  def links name, own: true, ids_name: nil, type: nil, table: nil, backfield: nil, linkfield: nil
    # TODO: implement
  end

  #
  # Связь один-ко-многим
  #
  def backs name, own: true, ids_name: nil, type: nil, backfield: nil
    # TODO: implement
  end

  def make data, cache: nil, from: :API
    raise TypeError, "'data' is not a valid Hash: #{data.inspect}!" unless Hash === data
    raise TypeError, "'cache' is not a valid EntitiesCache: #{cache.inspect}!" unless EntitiesCache === cache
    cache[self].make from: from, **data
  end

end
