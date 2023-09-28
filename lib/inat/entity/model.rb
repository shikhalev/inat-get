# frozen_string_literal: true

require_relative 'types'

# # structure forward declaration
# module Model
#   module Ext
#   end
# end

# module Model::Ext

# end

class Model

  class << self

    using Types

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

    def fields inherits = true
      @fields ||= {}
      result = @fields
      if inherits
        ancestors.each do |ancestor|
          if ancestor.respond_to?(:fields)
            af = ancestor.fields(false)
            result = af.merge result if Hash === af
          end
        end
      end
      result
    end

    def field name, id_name: nil, type: nil, required: false, index: nil, unique: nil, primary_key: nil, readonly: false
      raise ArgumentError, "Invalid field type: #{type}!" unless type.respond_to?(:make)
      name = name.intern
      define_method "#{name}" do
        instance_variable_get "@#{name}"
      end
      if !readonly
        define_method "#{name}=" do |value|
          instance_variable_set "@#{name}", type.make(value, cache: @cache)
        end
      end
      if Class === type && Entity > type && id_name != false
        id_name ||= "#{name}_id".intern
        id_name = id_name.intern
        define_method "#{id_name}" do
          instance_variable_get("@#{name}")&.id
        end
        if !readonly
          define_method "#{id_name}=" do |value|
            obj = if value.nil?
              nil
            else
              @cache[type][value]
            end
            instance_variable_set "@#{name}", obj
          end
        end
      end
      @fields ||= {}
      @fields[name] = {
        name: name,
        kind: :field,
        type: type,
        readonly: readonly,
      }
      @fields[name][:id_name] = id_name unless id_name.nil?
      @fields[name][:required] = required unless required.nil?
      @fields[name][:index] = index unless index.nil?
      @fields[name][:unique] = unique unless unique.nil?
      @fields[name][:primary_key] = primary_key unless primary_key.nil?
      @fields[name][:readonly] = readonly unless readonly.nil?
      @fields[name]
    end

    #
    # Связь многие-ко-многим
    #
    # TODO: добавить сортировку
    def links name, own: true, ids_name: nil, type: nil, table: nil, backfield: nil, linkfield: nil, readonly: false, index: nil
      raise ArgumentError, "Invalid field type: #{type.inspect}!" unless List === type
      raise ArgumentError, "'ids_name' parameter must be provided!" if ids_name.nil?
      name = name.intern
      define_method "#{name}" do
        instance_variable_get("@#{name}").dup.freeze
      end
      if !readonly
        define_method "#{name}=" do |value|
          instance_variable_set "@#{name}", type.make(value, cache: @cache)
        end
      end
      if ids_name != false
        ids_name = ids_name.intern
        define_method "#{ids_name}" do
          values = instance_variable_get "@#{name}"
          values&.map { |v| v.id }.freeze
        end
        if !readonly
          define_method "#{ids_name}=" do |value|
            values = nil
            values = @cache[type.item_class].get *value unless value.nil?
            instance_variable_set "@#{name}", values
          end
        end
      end
      table ||= "#{self.name.downcase}_#{name}".intern
      backfield ||= "#{self.name.downcase}_id".intern
      linkfield ||= "#{type.item_class.name.downcase}_id".intern
      @fields ||= {}
      @fields[name] = {
        name: name,
        kind: :links,
        type: type,
        readonly: readonly,
        ids_name: ids_name,
        own: own,
        table: table,
        backfield: backfield,
        linkfield: linkfield,
      }
      @fields[name][:index] = index unless index.nil?
      @fields[name]
    end

    #
    # Связь один-ко-многим
    #
    # TODO: добавить сортировку
    def backs name, own: true, ids_name: nil, type: nil, backfield: nil, readonly: false
      raise ArgumentError, "Invalid field type: #{type.inspect}!" unless List === type
      raise ArgumentError, "'ids_name' parameter must be provided!" if ids_name.nil?
      name = name.intern
      define_method "#{name}" do
        instance_variable_get("@#{name}").dup.freeze
      end
      if !readonly
        define_method "#{name}=" do |value|
          instance_variable_set "@#{name}", type.make(value, cache: @cache)
        end
      end
      if ids_name != false
        ids_name = ids_name.intern
        define_method "#{ids_name}" do
          values = instance_variable_get "@#{name}"
          values&.map { |v| v.id }.freeze
        end
        if !readonly
          define_method "#{ids_name}=" do |value|
            values = nil
            values = @cache[type.item_class].get *value unless value.nil?
            instance_variable_set "@#{name}", values
          end
        end
      end
      backfield ||= "#{self.name_downcase}_id".intern
      @fields ||= {}
      @fields[name] = {
        name: name,
        kind: :backs,
        type: type,
        readonly: readonly,
        ids_name: ids_name,
        own: own,
        backfield: backfield,
      }
      @fields[name]
    end

    def DDL
      inner = []
      outer = []
      fields.select { |_, i| !i[:readonly] }.each do |name, info|
        case info[:kind]
        when :field
          if Model > info[:type]
            # fld = "ALTER TABLE #{ self.table } ADD COLUMN #{ info[:id_name] } INTEGER REFERENCES #{ info[:type].table } (id)"
            fld = "#{ info[:id_name] } INTEGER REFERENCES #{ info[:type].table } (id)"
            if info[:unique]
              fld += ' UNIQUE'
            elsif info[:index]
              outer << "CREATE INDEX IF NOT EXISTS ix_#{ self.table }_#{ name } ON #{ self.table } (#{ info[:id_name] });"
            end
            inner << fld
          else
            fld = "#{ name } #{ info[:type].db_type }"
            if info[:primary_key]
              fld += ' PRIMARY KEY'
            elsif info[:unique]
              fld += ' UNIQUE'
            elsif info[:index]
              outer << "CREATE INDEX IF NOT EXISTS ix_#{ self.table }_#{ name } ON #{ self.table } (#{ name });"
            end
            inner << fld
          end
        when :links
          if info[:own]
            outer << "CREATE TABLE IF NOT EXISTS #{ info[:table] } (\n" +
                     "  #{ info[:backfield] } INTEGER REFERENCES #{ self.table } (id),\n" +
                     "  #{ info[:linkfield] } INTEGER REFERENCES #{ info[:type].item_class.table } (id),\n" +
                     "  PRIMARY KEY (#{ info[:backfield] }, #{ info[:linkfield] })\n" +
                     ");"
            outer << "CREATE INDEX IF NOT EXISTS ix_#{ info[:table] }_#{ info[:backfield] } ON #{ info[:table] } (#{ info[:backfield] });"
            if info[:index]
              outer << "CREATE INDEX IF NOT EXISTS ix_#{ info[:table] }_#{ info[:linkfield] } ON #{ info[:table] } (#{ info[:linkfield] });"
            end
          end
        end
      end
      tbl = "CREATE TABLE IF NOT EXISTS #{ self.table } (\n  #{ inner.join(",\n  ") }\n);\n"
      tbl + outer.join("\n")
    end

    def make data, cache: nil, from: :API
      return nil if data.nil?
      raise TypeError, "'data' is not a valid #{name} or Hash: #{data.inspect}!" unless Hash === data || self === data
      raise TypeError, "'cache' is not a valid EntitiesCache: #{cache.inspect}!" unless EntitiesCache === cache
      return data if self === data
      cache[self].make from: from, **data
    end

  end

  # def self.included mod
  #   mod.extend Model::Ext
  # end

  attr_reader :cache, :DB

  def DB
    @cache.DB
  end

  private def intersect? condition, value
    if Array === condition
      if Array === value
        condition.any? { |c| value.any? { |v| c === v } }
      else
        condition.any? { |c| c === value }
      end
    else
      if Array === value
        value.any? { |v| condition === v }
      else
        condition === value
      end
    end
  end

  # NOTE: Используется с перегрузкой для разных >/< и т.д.
  #       Здесь же тупо проверяются значния на вхождение в список.
  def matches? **query
    query.each do |key, value|
      key = key.intern
      if self.respond_to?(key)
        field_value = self.send key
        return false unless intersect?(value, field_value)
      end
    end
    return true
  end

  def apply! from: :API, **data
    fields = self.class.fields.select { |_, info| !info[:readonly] }
    data.each do |key, value|
      key = key.intern
      field = fields[key]
      if field
        if field[:kind] == :backs
          # NOTE: желательно бы избавиться от перебора...
          value = value.map { |v| v.merge { field[:backfield] => self } }
        end
        self.send "#{key}=", fields[key][:type].make(value, cache: @cache, from: from)
      else
        # TODO: warning
      end
    end
    @fetched = (from == :API)
    @stored = (from == :DB)
    self
  end

  # TODO: подумать, как вынести это дело в класс кэша или БД
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
      ids = items.map(&:id)
      DB.execute "DELETE FROM #{ info[:type].item_class.table } WHERE id NOT IN (#{ (['?'] * ids.size).join(',') })", *ids
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

  def fetched?
    @fetched || false
  end

  def stored?
    @stored || false
  end

end
