# frozen_string_literal: true

require_relative '../app/globals'

require_relative 'model'
require_relative 'ddl'
require_relative 'db'
require_relative 'api'

class Entity < Model

  include LogDSL

  class << self

    def inherited sub
      sub.send :init
      DDL << sub
    end

    private :new

    private def init
      @mutex = Mutex::new
    end

    private def update &block
      raise ArgumentError, "Block is required!", caller unless block_given?
      result = nil
      exception = nil
      @mutex.synchronize do
        begin
          result = block.call
        rescue Exception => e
          exception = e
        end
      end
      raise exception.class, exception.message, caller, cause: exception if exception
      result
    end

    private def get id
      update do
        @entities ||= {}
        @entities[id] ||= new id
        @entities[id]
      end
    end

    def fetch *ids
      return [] if ids.empty?
      result = ids.map { |id| get id }
      nc_ids = result.select { |e| !e.complete? }.map(&:id)
      read(*nc_ids)
      nc_ids = result.select { |e| !e.complete? }.map(&:id)
      load(*nc_ids)
      nc_ids = result.select { |e| !e.complete? }.map(&:id)
      warning "Some IDs were not fetched: #{ ids.join(', ') }!" unless nc_ids.empty?
      result
    end

    def read *ids
      return [] if ids.empty?
      # check = ids.dup
      result = []
      fields = self.fields
      data = DB.execute "SELECT * FROM #{ self.table } WHERE id IN (#{ (['?'] * ids.size).join(',') })", *ids
      data.each do |row|
        id = row['id'] || row[:id]
        raise TypeError, "Invalid data row: no 'id' field!" unless id
        # check.delete id
        entity = get id
        entity.update do
          fields.each do |_, field|
            case field.kind
            when :value
              name, value = field.from_db row
              if name != nil && value != nil
                entity.send "#{ name }=", value
              end
            when :links
              ids = DB.execute "SELECT #{ field.link_field } FROM #{ field.table_name } WHERE #{ field.back_field } = ?", entity.id
              entity.send "#{ field.id_field }=", ids
            when :backs
              # TODO: подумать над тем, чтобы сразу загрузить: вынести парсинг отдельно...
              ids = DB.execute "SELECT id FROM #{ field.type.table } WHERE #{ field.back_field } = ?", entity.id
              entity.send "#{ field.id_field }=", ids
            end
          end
        end
        result << entity
      end
      result
    end

    def load *ids
      return [] unless ids.empty? || @path.nil?
      data = API.get @path, *ids
      data.map { |obj| parse obj }
    end

    def parse src
      return nil if src == nil
      raise TypeError, "Source must be a Hash!" unless Hash === src
      id = src[:id] || src['id']
      raise ArgumentError, "Source must have an Integer 'id' value!", caller unless Integer === id
      fields = self.fields
      entity = self.get id
      entity.update do
        src.each do |key, value|
          key = key.intern if String === key
          field = fields[key]
          raise ArgumentError, "Field not found: '#{ key }'!", caller unless field
          if field.write?
            unless field.type === value
              if field.type.respond_to?(:parse)
                value = field.type.parse(value)
              else
                raise TypeError, "Invalid '#{ key }' value type: #{ value.inspect }!", caller
              end
            end
            entity.send "#{ key }=", value
          end
        end
      end
      entity
    end

    def ddl
      "INTEGER REFERENCES #{ self.table } (id)"
    end

  end

  field :id, type: Integer, primary_key: true

  def initialize id
    super
    self.id = id
  end

  def complete?
    self.class.fields.select { |f| f.required? }.all? { |f| send(f.name) != nil }
  end

  def save
    names = []
    values = []
    links = []
    backs = []
    update do
      fields.each do |_, field|
        case field.kind
        when :value
          name, value = field.to_db self.send(field.name)
          if name != nil && value != nil
            names += name
            values += value
          end
        when :links
          links << { field: field, values: self.send(field.name) } if field.owned
        when :backs
          backs << { field: field, values: self.send(field.name) } if field.owned
        end
      end
    end
    names = names.flatten
    values = values.flatten
    DB.transaction do |db|
      db.execute "INSERT OR REPLACE INTO #{ self.table } (#{ names.join(',') }) VALUES (#{ (['?'] * 3).join(',') });", *values
      links.each do |link|
        field = link[:field]
        values = link[:values]
        values.each do |value|
          value.save
          db.execute "INSERT OR REPLACE INTO #{ field.table_name } (#{ field.back_field }, #{ field.link_field }) VALUES (?, ?);", self.id, value.id
        end
        db.execute "DELETE FROM #{ field.table_name } WHERE #{ field.back_field } = ? AND #{ field.link_field } NOT IN (#{ (['?'] * values.size).join(',') });",
                    self.id, *values.map(&:id)
      end
      backs.each do |back|
        field = back[:field]
        values = back[:values]
        values.each do |value|
          value.send "#{ field.back_field }=", self.id
          value.save
        end
        db.execute "SELETE FROM #{ field.type.table } WHERE #{ field.back_field } = ? AND id NOT IN (#{ (['?'] * values.size).join(',') });",
                    self.id, *values.map(&:id)
      end
    end
  end

  def to_db
    self.id
  end

end
