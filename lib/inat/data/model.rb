# frozen_string_literal: true

require_relative '../app/globals'
require_relative 'types/std'

module INat::Data
  autoload :Entity, 'inat/data/entity'
end

module INat::Data; end

class INat::Data::Model

  include INat::App::Logger::DSL

  # @private
  class Field

    attr_reader :model, :name, :type, :id_field

    def required?
      false
    end

    def initialize model, name, type, id_field
      @model = model
      @name = name
      @type = type
      @id_field = id_field
    end

    def DDL
      [ [], [] ]
    end

    def from_db row
      [ nil, nil ]
    end

    def to_db value
      [ nil, nil ]
    end

    def kind
      nil
    end

  end

  # @private
  class ScalarField < Field

    using INat::Types::Std

    attr_reader :index, :unique, :primary_key

    def required?
      @required
    end

    def initialize model, name, type, id_field, required, index, unique, primary_key
      if Class === type && INat::Data::Entity > type && id_field == nil
        id_field = "#{ name }_id".intern
      end
      super model, name, type, id_field
      @required = required
      @index = index
      @unique = unique
      @primary_key = primary_key
    end

    def implement
      nm = @name
      md = @model
      rq = @required
      ni = @id_field
      tp = @type
      if ni
        md.define_method "#{ ni }" do
          instance_variable_get("@#{ ni }")
        end
        md.define_method "#{ ni }=" do |value|
          prevalue = instance_variable_get "@#{ ni }"
          if prevalue != value
            debug "ASS: #{ self.id }: #{ ni } = #{ prevalue.inspect } <=> #{ value.inspect }" if prevalue != nil && self.class.short_name == 'Taxon'
            instance_variable_set "@#{ ni }", value
            instance_variable_set "@saved", false
          end
        end
        md.define_method "#{ nm }" do
          v = instance_variable_get("@#{ ni }")
          return nil if v == nil
          r = tp.fetch v
          if r.size == 0
            nil
          else
            r.first
          end
        end
        md.define_method "#{ nm }=" do |value|
          prevalue = instance_variable_get "@#{ ni }"
          if prevalue != value&.id
            debug "ASS: #{ self.id }: #{ nm } / #{ ni } = #{ prevalue.inspect } <=> #{ value.inspect }" if prevalue != nil && self.class.short_name == 'Taxon'
            instance_variable_set "@#{ ni }", value&.id
            instance_variable_set "@saved", false
          end
        end
      else
        md.define_method "#{ nm }" do
          instance_variable_get "@#{ nm }"
        end
        md.define_method "#{ nm }=" do |value|
          raise TypeError, "Invalid '#{ nm }' value: #{ value.inspect }!", caller unless tp === value || (value == nil && !rq)
          prevalue = instance_variable_get "@#{ nm }"
          if prevalue != value
            debug "ASS: #{ self.id }: #{ nm } = #{ prevalue.inspect } <=> #{ value.inspect }" if prevalue != nil && self.class.short_name == 'Taxon'
            instance_variable_set "@#{ nm }", value
            instance_variable_set "@saved", false
          end
        end
      end
    end

    def read?
      true
    end

    def write?
      true
    end

    def DDL
      inner = ''
      outer = []
      ddl_name = @id_field || @name
      type_ddl = @type.ddl
      case type_ddl
      when String, Symbol
        inner = "  #{ ddl_name } #{ type_ddl }"
        if @primary_key
          inner += ' NOT NULL PRIMARY KEY'
        elsif @unique
          outer << "CREATE UNIQUE INDEX IF NOT EXISTS uq_#{ @model.table }_#{ ddl_name } ON #{ @model.table } (#{ ddl_name });"
        elsif @index
          outer << "CREATE INDEX IF NOT EXISTS ix_#{ @model.table }_#{ ddl_name } ON #{ @model.table } (#{ ddl_name });"
        end
      when Hash
        inner = []
        names = []
        type_ddl.each do |k, v|
          inner << "  #{ ddl_name }_#{ k } #{ v }"
          names << "#{ ddl_name }_#{ k }"
        end
        if @unique
          outer << "CREATE UNIQUE INDEX IF NOT EXISTS uq_#{ @model.table }_#{ ddl_name } ON #{ @model.table } (#{ names.join(',') });"
        elsif @index
          outer << "CREATE INDEX IF NOT EXISTS ix_#{ @model.table }_#{ ddl_name } ON #{ @model.table } (#{ names.join(',') });"
        end
      else
        raise TypeError, "Invalid type DDL: #{ type_ddl.inspect }", caller
      end
      [ inner, outer ]
    end

    def from_db row
      ddl_name = @id_field || @name
      type_ddl = @type.ddl
      value = nil
      case type_ddl
      when String, Symbol
        value = row[ddl_name.to_s]
        value = @type.from_db value unless @id_field || @type === value
      when Hash
        value = {}
        type_ddl.each do |k, v|
          value[k] = row["#{ ddl_name }_#{k}"]
        end
        value = @type.from_db value
      else
        raise TypeError, "Invalid type DDL: #{ type_ddl.inspect }!", caller
      end
      [ ddl_name, value ]
    end

    def to_db value
      ddl_name = @id_field || @name
      type_ddl = @type.ddl
      case type_ddl
      when String, Symbol
        [ ddl_name, value.to_db ]
      when Hash
        keys = []
        values = []
        if value != nil
          hash = value.to_db
          hash.each do |k, v|
            keys << "#{ ddl_name }_#{ k }"
            values << v
          end
        else
          type_ddl.each do |k, _|
            keys << "#{ ddl_name }_#{ k }"
            values << nil
          end
        end
        [ keys, values ]
      else
        raise TypeError, "Invalid type DDL: #{ type_ddl.inspect }!", caller
      end
    end

    def kind
      :value
    end

  end

  # @private
  class ArrayField < Field

    using INat::Types::Std

    attr_reader :back_field

    def owned?
      @owned
    end

    def initialize model, name, type, id_field, owned, back_field
      if id_field == nil
        if name.end_with?('s')
          id_field = "#{ name[..-2] }_ids".intern
        else
          raise ArgumentError, "Argument 'id_field' is required for name '#{ name }'!", caller[1..]
        end
      end
      back_field = "#{ model.short_name.downcase }_id".intern if back_field == nil
      super model, name, type, id_field
      @owned = owned
      @back_field = back_field
    end

    def implement
      nm = @name
      md = @model
      # rq = @required
      ni = @id_field
      tp = @type
      if ni
        md.define_method "#{ ni }" do
          instance_variable_get("@#{ ni }") || []
        end
        md.define_method "#{ ni }=" do |value|
          prevalue = instance_variable_get "@#{ ni }"
          if ni.intern == :ancestor_ids
            prevalue&.delete(self.id)
            value&.delete(self.id)
            value&.prepend 48460
            value = value&.sort.uniq
          end
          if prevalue != value
            debug "ASS: #{ self.id }: #{ ni } = #{ prevalue.inspect } <=> #{ value.inspect } :: #{ caller[..2] }" if prevalue != nil && self.class.short_name == 'Taxon'
            instance_variable_set "@#{ ni }", value
            instance_variable_set "@saved", false
          end
        end
        md.define_method "#{ nm }" do
          tp.fetch(*(instance_variable_get("@#{ ni }") || []))
        end
        md.define_method "#{ nm }=" do |value|
          value ||= []
          # value.each do |v|
          #   raise TypeError, "Invalid #{ nm } value: #{ v.inspect }!", caller unless tp === v
          # end
          self.send "#{ ni }=", value.map(&:id)
        end
      else
        md.define_method "#{ nm }" do
          instance_variable_get("@#{ nm }") || []
        end
        md.define_method "#{ nm }=" do |value|
          value ||= []
          value.each do |v|
            raise TypeError, "Invalid #{ nm } value: #{ v.inspect }!", caller unless tp === v
          end
          prevalue = instance_variable_get("@#{ nm }")
          if prevalue&.sort != value&.sort
            debug "ASS: #{ self.id }: #{ nm } = #{ prevalue.inspect } <=> #{ value.inspect } :: #{ caller[..2] }" if prevalue != nil && self.class.short_name == 'Taxon'
            instance_variable_set "@#{ nm }", value
            instance_variable_set "@saved", false
          end
        end
      end
    end

    def read?
      true
    end

    def write?
      @owned
    end

  end

  # @private
  class ManyToManyField < ArrayField

    using INat::Types::Std

    attr_reader :table_name, :link_field, :index

    def initialize model, name, type, id_field, owned, table_name, back_field, link_field, index
      table_name = "#{ model.short_name.downcase }_#{ name }".intern if table_name == nil
      link_field = "#{ type.short_name.downcase }_id".intern         if link_field == nil
      super model, name, type, id_field, owned, back_field
      @table_name = table_name
      @link_field = link_field
      @index = index
    end

    def DDL
      outer = []
      if @owned
        outer << "\nCREATE TABLE IF NOT EXISTS #{ @table_name } (\n" +
                 "  #{ back_field } INTEGER NOT NULL REFERENCES #{ @model.table } (id),\n" +
                 "  #{ link_field } INTEGER NOT NULL REFERENCES #{ @type.table } (id),\n" +
                 "  PRIMARY KEY (#{ back_field }, #{ link_field })\n" +
                 ");"
        outer << "CREATE INDEX IF NOT EXISTS ix_#{ @table_name }_#{ back_field } ON #{ @table_name } (#{ back_field });"
        if @index
          outer << "CREATE INDEX IF NOT EXISTS ix_#{ @table_name }_#{ link_field } ON #{ @table_name } (#{ link_field });"
        end
      end
      [ [], outer ]
    end

    def kind
      :links
    end

  end

  # @private
  class OneToManyField < ArrayField

    def kind
      :backs
    end

  end

  # @private
  class SpecialField < Field

    def initialize model, name, type, &block
      raise ArgumentError, "Block is required!", caller[1..] unless block_given?
      super model, name, type, nil
      @block = block
    end

    def implement
      nm = @name
      md = @model
      md.define_method "#{ nm }=", &@block
    end

    def read?
      false
    end

    def write?
      true
    end

  end

  # @private
  class IgnoreField < SpecialField

    def initialize model, name
      super model, name, Object do
        nil
      end
    end

    def implement
    end

    def read?
      false
    end

    def write?
      false
    end

  end

  private_constant :Field, :ScalarField, :ArrayField, :ManyToManyField, :OneToManyField, :SpecialField, :IgnoreField

  class << self

    def api_path name = nil
      raise TypeError, "Path name must be a Symbol!", caller unless name == nil || Symbol === name
      @api_path = name if name != nil
      @api_path
    end

    def has_path?
      !!@api_path
    end

    def api_part part = nil
      raise TypeError, "Part name must be a Symbol!", caller unless part == nil || Symbol === part
      @api_part = part if part != nil
      @api_part
    end

    def api_limit limit = nil
      raise TypeError, "Part name must be an Integer!", caller unless limit == nil || Integer === limit
      @api_limit = limit if limit != nil
      @api_limit
    end

    def table name = nil
      raise TypeError, "Table name must be a Symbol!", caller unless name == nil || Symbol === name
      @table = name if name != nil
      @table
    end

    def has_table?
      !!@table
    end

    def fields include_super = true
      @fields ||= {}
      result = {}
      if include_super
        ancestors.reverse.each do |ancestor|
          if ancestor != self && ancestor.respond_to?(:fields)
            ancestor_fields = ancestor.fields
            if Hash === ancestor_fields
              result.merge! ancestor_fields
            end
          end
        end
      end
      result.merge! @fields
      result.freeze
    end

    # Defines a new field
    # @param [Symbol] name
    # @param [Class] type
    # @return [void]
    # @!macro [attach] field
    #   @api public
    #   @!attribute [rw]
    #   @return [$2] the +$1+ field
    def field name, type: nil, id_field: nil, required: false, index: false, unique: false, primary_key: false
      raise TypeError, "Field name must be a Symbol!", caller              unless Symbol === name
      raise TypeError, "Field type must be a Module!", caller              unless Module === type
      raise TypeError, "Argument 'id_field' must be a Symbol!", caller     unless Symbol === id_field || id_field == nil
      raise TypeError, "Argument 'required' must be a Boolean!", caller    unless Boolean === required
      raise TypeError, "Argument 'index' must be a Boolean!", caller       unless Boolean === index
      raise TypeError, "Argument 'unique' must be a Boolean!", caller      unless Boolean === unique
      raise TypeError, "Argument 'primary_key' must be a Boolean!", caller unless Boolean === primary_key
      @fields ||= {}
      @fields[name] = ScalarField::new self, name, type, id_field, required, index, unique, primary_key
      @fields[name].implement
    end

    # Defines a new many-to-many field
    # @param [Symbol] name
    # @param [Class] item_type
    # @return [void]
    # @!macro [attach] links
    #   @api public
    #   @!attribute [rw]
    #   @return [Array<$2>] the +$1+ field
    def links name, item_type: nil, ids_field: nil, owned: true, table_name: nil, back_field: nil, link_field: nil, index: false
      raise TypeError, "Field name must be a Symbol!", caller            unless Symbol === name
      raise TypeError, "Item type must be an Entity subclass!", caller   unless Class === item_type && INat::Entity > item_type
      raise TypeError, "Argument 'ids_field' must be a Symbol!", caller  unless Symbol === ids_field || ids_field == nil
      raise TypeError, "Argument 'table_name' must be a Symbol!", caller unless Symbol === table_name || table_name == nil
      raise TypeError, "Argument 'back_field' must be a Symbol!", caller unless Symbol === back_field || back_field == nil
      raise TypeError, "Argument 'link_field' must be a Symbol!", caller unless Symbol === link_field || link_field == nil
      raise TypeError, "Argument 'owned' must be a Boolean!", caller     unless Boolean === owned
      raise TypeError, "Argument 'index' must be a Boolean!", caller     unless Boolean === index
      @fields ||= {}
      @fields[name] = ManyToManyField::new self, name, item_type, ids_field, owned, table_name, back_field, link_field, index
      @fields[name].implement
    end

    # Defines a new one-to-many field
    # @param [Symbol] name
    # @param [Class] item_type
    # @return [void]
    # @!macro [attach] backs
    #   @api public
    #   @!attribute [rw]
    #   @return [Array<$2>] the +$1+ field
    def backs name, item_type: nil, ids_field: nil, owned: true, back_field: nil
      raise TypeError, "Field name must be a Symbol!", caller            unless Symbol === name
      raise TypeError, "Item type must be an Entity subclass!", caller   unless Class === item_type && INat::Entity > item_type
      raise TypeError, "Argument 'ids_field' must be a Symbol!", caller  unless Symbol === ids_field || ids_field == nil
      raise TypeError, "Argument 'back_field' must be a Symbol!", caller unless Symbol === back_field || back_field == nil
      raise TypeError, "Argument 'owned' must be a Boolean!", caller     unless Boolean === owned
      @fields ||= {}
      @fields[name] = OneToManyField::new self, name, item_type, ids_field, owned, back_field
      @fields[name].implement
    end

    # Defines a new write-only field
    # @param [Symbol] name
    # @param [Class] type
    # @return [void]
    # @!macro [attach] block
    #   @api public
    #   @!attribute [w]
    #   @return [$2] the +$1+ field
    def block name, type: nil, &block
      raise TypeError, "Field name must be a Symbol!", caller unless Symbol === name
      raise TypeError, "Field type must be a Module!", caller unless Module === type
      raise ArgumentError, "Block is required!", caller          unless block_given?
      @fields ||= {}
      @fields[name] = SpecialField::new self, name, type, &block
      @fields[name].implement
    end

    private def ignore *names
      @fields ||= {}
      names.each do |name|
        raise TypeError, "Field name must be a Symbol!", caller unless Symbol === name
        @fields[name] = IgnoreField::new self, name
        @fields[name].implement
      end
    end

    def DDL
      inner = []
      outer = []
      fields.each do |_, field|
        i, o = field.DDL
        inner << i
        outer << o
      end
      "CREATE TABLE IF NOT EXISTS #{ @table } (\n#{ inner.flatten.join(",\n") }\n);\n" + "#{ outer.flatten.join("\n") }\n\n"
    end

  end

  def initialize
    @mutex = Mutex::new
  end

  def process?
    @process
  end

  def saved?
    @saved
  end

  def post_update
    # do nothing
  end

  def update(from_db: false)
    raise ArgumentError, "Block is required!", caller unless block_given?
    @process = true
    @saved = true if from_db
    result = nil
    exception = nil
    @mutex.synchronize do
      begin
        result = yield
        post_update unless from_db
      rescue Exception => e
        exception = e
      end
    end
    @saved = true if from_db
    @process = false
    raise exception.class, exception.message, caller, cause: exception if exception
    result
  end

  def to_h
    result = {}
    self.class.fields.each do |key, field|
      if field.read?
        result[key] = send "#{ key }"
      end
    end
    result.freeze
  end

end
