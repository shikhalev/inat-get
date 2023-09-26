# frozen_string_literal: true

require 'time'
require 'date'

require_relative 'types'

module Model

  using Types

  module Ext

    using Types

    def field name, type: String, unique: false, index: false, primary_key: false, ids_name: null

      nm = name.intern
      tp = type
      info = {
        type: type,
      }

      if Model === type
        # Model
        define_method "#{nm}" do
          instance_variable_get "@#{nm}"
        end
        define_method "#{nm}_id" do
          instance_variable_get("@#{nm}")&.id
        end
        define_method "#{nm}=" do |value|
          instance_variable_set "@#{nm}", tp.from_api(@cache, value)
        end
        define_method "#{nm}_id=" do |value|
          instance_variable_set "@#{nm}", tp.from_api(@cache, { id: value })
        end
        info[:field_sql] = "#{name}_id INTEGER REFERENCES #{type.table} (id)"
        if index
          info[:append_sql] = "CREATE INDEX IF NOT EXISTS ix_#{self.table}_#{name} ON #{self.table} (#{name}_id)"
        end
        info[:index] = index
      elsif Items === type
        if Model === type.item_class
          # Список связанных сущностей...
          idnm = (ids_name || "#{nm}_ids").intern
          define_method "#{nm}" do
            instance_variable_get "@#{nm}"
          end
          define_method "#{idnm}" do
            instance_variable_get("@#{nm}")&.map { |i| i&.id }
          end
          define_method "#{nm}=" do |value|
            instance_variable_set "@#{nm}", value&.map { |v| tp.from_api(@cache, v) }
          end
          define_method "#{idnm}=" do |value|
            instance_variable_set "@#{nm}", value&.map { |v| tp.from_api(@cache, { id: v }) }
          end
          info[:append_sql] = "CREATE TABLE IF NOT EXISTS #{self.name.downcase}_#{type.item_class.table} (\n"
          info[:append_sql] += "#{self.name.downcase}_id INTEGER REFERENCES #{self.table} (id),\n"
          info[:append_sql] += "#{type.item_class.name.downcase}_id INTEGER REFERENCES #{type.item_class.table} (id),\n"
          info[:append_sql] += ");\n"
          info[:append_sql] += "CREATE UNIQUE INDEX IF NOT EXISTS pk_#{self.name.downcase}_#{type.item_class.table} ON #{self.name.downcase}_#{type.item_class.table} (#{self.name.downcase}_id, #{type.item_class.name.downcase}_id);"
        else
          # Списки обычных типов, непонятно зачем...
          define_method "#{nm}" do
            instance_variable_get "@#{nm}"
          end
          define_method "#{nm}=" do |value|
            instance_variable_set "@#{nm}", value.map { |v| tp.item_class.from_api(v) }
          end
          # TODO: продумать способ хранения (используется для тегов...)
          info[:field_sql] = "#{name} TEXT"
          # TODO: добавить варнинг о том, что такой тип имеет проблемы
        end
      else
        # Simple type
        define_method "#{nm}" do
          instance_variable_get "@#{nm}"
        end
        define_method "#{nm}=" do |value|
          instance_variable_set "@#{nm}", tp.from_api(value)
        end
        info[:field_sql] = "#{name} #{type.db_type}"
        info[:field_sql] += " PRIMARY KEY" if primary_key
        info[:field_sql] += " UNIQUE" if unique && !primary_key
        if index && !unique && !primary_key
          info[:append_sql] = "CREATE INDEX IF NOT EXISTS uq_#{self.table}_#{name} ON #{self.table} (#{name})"
        end
        info[:primary_key] = primary_key if primary_key
        info[:index] = index
        info[:unique] = unique
      end

      @fields ||= {}
      @fields[nm] = info

    end

    def fields inhers = true
      @fields ||= {}
      result = {}
      if inhers
        ancestors.each do |ancestor|
          if ancestor.respond_to?(:fields)
            result.merge! ancestor.fields(false)
          end
        end
      end
      result.merge! @fields
      result
    end

    def table name = nil
      @table = name if name
      @table
    end

    def path url = nil
      @path = url if url
      @path
    end

    def from_api cache, data
      return data if self === data
      obj = cache.get_object self, data['id'] || data[:id]
      obj.send :from_api! data
    end

    def from_db cache, data
      return data if self === data
      obj = cache.get_object self, data['id'] || data[:id]
      obj.send :from_db! data
    end

  end

  def self.models
    @models ||= []
    @models
  end

  def self.included mod
    mod.extend Ext
    @models ||= []
    @models << mod
  end

  def from_api! data
    data.each do |key, value|
      field = self.class.fields[key.intern]
      if field
        self.send "#{key}=", field[:type].from_api(value)
      end
    end
    self
  end

  def from_db! data
    data.each do |key, value|
      field = self.class.fields[key.intern]
      if field
        self.send "#{key}=", field[:type].from_db(value)
      end
    end
    self
  end

  def to_db
    # TODO:
  end

  def to_query_param
    # TODO:
  end

end
