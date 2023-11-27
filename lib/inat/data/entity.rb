# frozen_string_literal: true

require_relative '../app/globals'

require_relative 'model'
require_relative 'ddl'
require_relative 'db'
require_relative 'api'

class INat::Entity < INat::Data::Model

  include INat
  include INat::App::Logger::DSL

  class << self

    include INat
    include INat::App::Logger::DSL

    def inherited sub
      sub.send :init
      Data::DDL << sub
    end

    private :new

    private def init
      @mutex = Mutex::new
    end

    private def update
      raise ArgumentError, "Block is required!", caller unless block_given?
      result = nil
      exception = nil
      @mutex.synchronize do
        begin
          result = yield
        rescue Exception => e
          exception = e
        end
      end
      raise exception.class, exception.message, caller, cause: exception if exception
      result
    end

    private def get id
      return nil if id == nil
      update do
        @entities ||= {}
        @entities[id] ||= new id
        @entities[id]
      end
    end

    def fetch *ids
      return [] if ids.empty?
      # sids = if ids.size > 7
      #   ids.take(7).map(&:to_s) + [ 'and more' ]
      # else
      #   ids.map(&:to_s)
      # end
      # Status::status '[fetch]', "#{ self } : " + sids.join(', ') + ' ...'
      result = ids.map { |id| get id }.filter { |x| x != nil }
      nc_ids = result.select { |e| !e.complete? && !e.process? }.map(&:id)
      read(*nc_ids)
      nc_ids = result.select { |e| !e.complete? && !e.process? }.map(&:id)
      load(*nc_ids)
      nc_ids = result.select { |e| !e.complete? && !e.process? }.map(&:id)
      warning "Some #{ self } IDs were not fetched: #{ nc_ids.join(', ') }!" unless nc_ids.empty?
      # result = [ nil ] if result == []
      # Status::status '[fetch]', "#{ self } : " + sids.join(', ') + ' DONE'
      result
    end

    def by_id id
      fetch(id).first
    end

    # TODO: подумать о переименовании
    def from_db_rows data
      result = []
      data.each do |row|
        id = row['id'] || row[:id]
        raise TypeError, "Invalid data row: no 'id' field!" unless id
        # check.delete id
        entity = get id
        entity.update(from_db: true) do
          fields.each do |_, field|
            case field.kind
            when :value
              name, value = field.from_db row
              if name != nil && value != nil
                entity.send "#{ name }=", value
              end
            when :links
              ids = DB.execute("SELECT #{ field.link_field } FROM #{ field.table_name } WHERE #{ field.back_field } = ?", entity.id).map { |x| x[field.link_field.to_s] }
              entity.send "#{ field.id_field }=", ids
            when :backs
              # TODO: подумать над тем, чтобы сразу загрузить: вынести парсинг отдельно...
              ids = DB.execute("SELECT id FROM #{ field.type.table } WHERE #{ field.back_field } = ?", entity.id).map { |x| x['id'] }
              entity.send "#{ field.id_field }=", ids
            end
          end
        end
        result << entity
      end
      result
    end

    def read *ids
      return [] if ids.empty?
      # check = ids.dup
      # fields = self.fields
      data = DB.execute "SELECT * FROM #{ self.table } WHERE id IN (#{ (['?'] * ids.size).join(',') })", *ids
      from_db_rows data
    end

    def load *ids
      return [] if ids.empty? || @api_path.nil?
      data = INat::API.get @api_path, @api_part, @api_limit, *ids
      data.map { |obj| parse obj }
    end

    def load_file filename
      data = API.load_file filename
      data.map { |obj| parse obj }
    end

    def parse src
      return nil if src == nil
      raise TypeError, "Source must be a Hash! (#{ src.inspect })" unless Hash === src
      # if !(Hash === src)
      #   warning "INVALID SOURCE for #{ self }: #{ src.inspect }"
      #   return nil
      # end
      id = src[:id] || src['id']
      raise ArgumentError, "Source must have an Integer 'id' value!", caller unless Integer === id
      fields = self.fields
      entity = self.get id
      entity.update do
        src.each do |key, value|
          key = key.intern if String === key
          field = fields[key] || fields.values.find { |f| f.id_field == key }
          raise ArgumentError, "Field not found in #{ self.name }: '#{ key }'!", caller unless field
          if field.write?
            unless (field.type === value) || (field.id_field == key && Integer === value)
              if field.id_field == key
                # do nothing
              elsif field.type.respond_to?(:parse)
                if Array === value
                  if field.kind == :backs
                    value = value.map { |v| field.type.parse(v.merge(field.back_field => entity.id)) }
                  else
                    value = value.map { |v| field.type.parse(v) }
                  end
                else
                  value = field.type.parse(value)
                end
              else
                raise TypeError, "Invalid '#{ key }' value type: #{ value.inspect }!", caller
              end
            end
            entity.send "#{ key }=", value
          end
        end
      end
      entity
      # entity.save
    end

    def ddl
      "INTEGER REFERENCES #{ self.table } (id)"
    end

  end

  field :id, type: Integer, primary_key: true

  def initialize id
    super()
    self.id = id
    # @saved = true
    @s_count = 0
  end

  def complete?
    fields = self.class.fields.values.select { |f| f.required? }
    # values = fields.map { |f| [ f.name, send(f.name) ] }
    fields.all? { |f| send(f.name) != nil }
  end

  def save
    return self if @saved
    # debug "Save #{ self.class.name } id = #{ self.id } saved = #{ @saved.inspect }"
    @s_count += 1
    debug "Saving count = #{ @s_count } [#{ self.class }: #{ self.id }]" if @s_count > 1
    names = []
    values = []
    links = []
    backs = []
    # update do
      self.class.fields.each do |_, field|
        case field.kind
        when :value
          value = self.send(field.name)
          if INat::Entity === value && value != self # && !value.process?
            value.save
          end
          name, value = field.to_db value
          if name != nil && value != nil
            names << name
            values << value
          end
        when :links
          links << { field: field, values: self.send(field.name) } if field.owned?
        when :backs
          backs << { field: field, values: self.send(field.name) } if field.owned?
        end
      end
    # end
    names = names.flatten
    values = values.flatten
    # DB.transaction do |db|
      DB.execute "INSERT OR REPLACE INTO #{ self.class.table } (#{ names.join(',') }) VALUES (#{ (['?'] * values.size).join(',') });", *values
      @saved = true
      links.each do |link|
        field = link[:field]
        values = link[:values]
        olinks = []
        values.each do |value|
          value.save if value != self
          # DB.execute "INSERT OR REPLACE INTO #{ field.table_name } (#{ field.back_field }, #{ field.link_field }) VALUES (?, ?);", self.id, value.id
          olinks << "INSERT OR REPLACE INTO #{ field.table_name } (#{ field.back_field }, #{ field.link_field }) VALUES (#{ self.id }, #{ value.id });"
        end
        DB.execute_batch olinks.join("\n")
        news = values.map(&:id)
        olds = DB.execute("SELECT #{ field.link_field } as id FROM #{ field.table_name } WHERE #{ field.back_field } = ?;", self.id).map { |r| r['id'] }
        diff = olds.filter { |o| !news.include?(o) }
        if !diff.empty?
          DB.execute "DELETE FROM #{ field.table_name } WHERE #{ field.back_field } = ? AND #{ field.link_field } IN (#{ (['?'] * diff.size).join(',') });",
                      self.id, *diff
        end
      end
      backs.each do |back|
        field = back[:field]
        values = back[:values]
        values.each do |value|
          value.send "#{ field.back_field }=", self.id
          value.save if value != self
        end
        news = values.map(&:id)
        olds = DB.execute("SELECT id FROM #{ field.type.table } WHERE #{ field.back_field } = ?;", self.id).map { |r| r['id'] }
        diff = olds.filter { |o| !news.include?(o) }
        if !diff.empty?
          DB.execute "DELETE FROM #{ field.type.table } WHERE #{ field.back_field } = ? AND id IN (#{ (['?'] * diff.size).join(',') });",
                      self.id, *diff
        end
      end
    # end
    # @saved = true
    # TODO: разобраться и почистить двойное присваивание
    self
  end

  def to_db
    self.id
  end

end

module INat::Entity::BySLUG

  include INat

  def by_slug slug
    # Status::status '[fetch]', "#{ self } : #{ slug } ..."
    @entities ||= {}
    results = @entities.values.select { |e| e.slug == slug.intern }
    if results.empty?
      data = DB.execute "SELECT * FROM #{ table } WHERE slug = ?", slug.to_s
      results = from_db_rows data
    end
    if results.empty?
      data = INat::API.get @api_path, :path, 1, slug
      results = data.map { |d| parse(d) }
    end
    # Status::status '[fetch]', "#{ self } : #{ slug } DONE"
    if results.empty?
      nil
    else
      results.first
    end
  end

end
