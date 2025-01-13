
require 'pp'

require_relative './mod'
require_relative './list'

module ING::DBO::Type

  def type_name
    self.name
  end

  def DDL name
    { "#{ name }" => "#{ type_name }" }
  end

end

class ING::DBO::Field

  attr_reader :name, :type, :required, :source_aliases

  def initialize name, type, required, source_aliases
    @name = name
    @type = type
    @required = required
    @source_aliases = source_aliases
  end

  def validate value
    # default validation - check type
    if value == nil
      raise ArgumentError, "Invalid #{ @name } value: #{ value.inspect }", caller if @required
    else
      raise ArgumentError, "Invalid #{ @name } value: #{ value.inspect }", caller unless @type === value
    end
    value
  end

end

class ING::DBO::DataField < ING::DBO::Field

  attr_reader :index, :unique, :primary_key, :column

  def initialize name, type, required, index, unique, primary_key, column, source_aliases
    super name, type, required, source_aliases
    @index = index
    @unique = unique
    @primary_key = primary_key
    @column = column
  end

  def DDL dbo
    data_ddl = @type.DDL @column
    cols = data_ddl.map { |nm, tp| "#{ nm } #{ tp }#{ @required ? ' NOT NULL' : '' }" }
    keys = []
    refs = []
    inds = []
    lnks = []
    if @primary_key
      keys = [ "pk_#{ dbo.table } PRIMARY KEY (#{ data_ddl.keys.join(', ') })" ]
    elsif @unique
      keys = [ "uq_#{ dbo.table }_#{ @name } UNIQUE (#{ data_ddl.keys.join(', ') })" ]
    elsif @index
      index_key = Symbol === @index ? " #{ @index }".uppercase : ''
      inds = [ "ix_#{ dbo.table }_#{ @name } ON #{ dbo.table } (#{ data_ddl.keys.join(', ') })#{ index_key }" ]
    end
    [ cols, keys, refs, inds, lnks ]
  end

end

class ING::DBO::ObjectField < ING::DBO::DataField

  attr_reader :id_name

  def initialize name, id_name, type, required, index, unique, primary_key, column, source_aliases
    super name, type, required, index, unique, primary_key, column, source_aliases
    @id_name = id_name
  end

  def validate_id value
    result = nil
    if value == nil
      raise ArgumentError, "Invalid #{ @id_name } value: #{ value.inspect }", caller if @required
    else
      raise ArgumentError, "Invalid #{ @id_name } value: #{ value.inspect }", caller unless Integer === value
      result = @type.get value
      raise ArgumentError, "Object not found with id = #{ value.inspect }", caller if result == nil
    end
    result
  end

  def DDL dbo
    cols = [ "#{ @column } BIGINT#{ @required ? ' NOT NULL' : '' }" ]
    keys = []
    refs = [ "fk_#{ dbo.table }_#{ @name } FOREIGN KEY (#{ @column }) REFERENCES #{ @type.table } (id)" ]
    inds = []
    lnks = []
    if @primary_key
      keys = [ "pk_#{ dbo.table } PRIMARY KEY (#{ @column })" ]
    elsif @unique
      keys = [ "uq_#{ dbo.table }_#{ @name } UNIQUE (#{ @column })" ]
    elsif @index
      inds = [ "ix_#{ dbo.table }_#{ @name } ON #{ dbo.table } (#{ @column })" ]
    end
    [ cols, keys, refs, inds, lnks ]
  end

end

class ING::DBO::ArrayField < ING::DBO::Field

  attr_reader :id_name, :owned, :back_column

  def initialize name, id_name, type, owned, back_column, source_aliases
    super name, type, false, source_aliases
    @id_name = id_name
    @owned = owned
    @back_column = back_column
  end

  def validate values
    values ||= []
    raise ArgumentError, "Invalid #{ @name } value: #{ values.inspect }", caller if values.any? { |v| !(@type.type === v) }
    values
  end

end

class ING::DBO::LinksField < ING::DBO::ArrayField

  attr_reader :link_table, :link_column

  def initialize name, id_name, type, owned, link_table, back_column, link_column, source_aliases
    super name, id_name, type, owned, back_column, source_aliases
    @link_table = link_table
    @link_column = link_column
  end

  def DDL dbo
    cols = []
    keys = []
    refs = []
    inds = [ "ix_#{ @link_table }_back ON #{ @link_table } (#{ @back_column })",
             "ix_#{ @link_table }_link ON #{ @link_table } (#{ @link_column })" ]
    lnks = [ "CREATE TABLE #{ @link_table } (\n" +
             "  #{ @back_column } BIGINT NOT NULL,\n" +
             "  #{ @link_column } BIGINT NOT NULL,\n" +
             "CONSTRAINT pk_#{ @link_table } PRIMARY KEY (#{ @back_column }, #{ @link_column }),\n" +
             "CONSTRAINT fk_#{ @link_table }_back FOREIGN KEY (#{ @back_column }) REFERENCES #{ dbo.table } (id),\n" +
             "CONSTRAINT fk_#{ @link_table }_link FOREIGN KEY (#{ @link_column }) REFERENCES #{ @type.type.table } (id)\n" +
             ")" ]
    [ cols, keys, refs, inds, lnks ]
  end

end

class ING::DBO::BacksField < ING::DBO::ArrayField

  def initialize name, id_name, type, owned, back_column, source_aliases
    super name, id_name, type, owned, back_column, source_aliases
  end

  def DDL dbo
    [ [], [], [], [], [] ]
  end

end

module ING::DBO::DDL

  include ING::DBO::Type

  private def check_name name
    sname = case name
    when String
      name
    when Symbol
      name.to_s
    else
      raise ArgumentError, "Invalid name type: #{ name.inspect }", caller[1..]
    end
    unless /^[a-zA-Z]\w*$/ === sname
      raise ArgumentError, "Invalid name: #{ name.inspect }", caller[1..]
    end
    sname.intern
  end

  def short_name
    @short_name = name.split('::').last.downcase.intern
    @short_name
  end

  def table name = nil
    @table = check_name name if name
    @table
  end

  protected def field name, from_id: nil, type: nil, required: false, index: false, unique: false, primary_key: false, column: nil, source_aliases: []
    raise ArgumentError, "Invalid type: #{ type.inspect }", caller unless ING::DBO::Type === type && Module === type
    nm = check_name name
    @fields ||= {}
    if type.method_defined?(:id)
      id = if from_id
        check_name from_id
      else
        "#{ nm }_id".intern
      end
      cl = check_name(column || id)
      fld = ING::DBO::ObjectField::new nm, id, type, required, index, unique, primary_key, cl, source_aliases
      self.define_method "#{ nm }" do
        instance_variable_get "@#{ nm }"
      end
      self.define_method "#{ id }" do
        v = instance_variable_get "@#{ nm }"
        v && v.id
      end
      self.define_method "#{ nm }=" do |value|
        v = fld.validate value
        instance_variable_set "@#{ nm }", v
      end
      self.define_method "#{ id }=" do |value|
        v = fld.validate_id value
        instance_variable_set "@#{ nm }", v
      end
      @fields[nm] = fld
    else
      cl = check_name(column || nm)
      fld = ING::DBO::DataField::new nm, type, required, index, unique, primary_key, cl, source_aliases
      self.define_method "#{ nm }" do
        instance_variable_get "@#{ nm }"
      end
      self.define_method "#{ nm }=" do |value|
        v = fld.validate value
        instance_variable_set "@#{ nm }", v
      end
      @fields[nm] = fld
    end
  end

  private def uns name
    nm = name.to_s
    if nm.end_with?('s')
      nm[..-1]
    else
      nm
    end
  end

  # индексы строятся всегда
  protected def links name, from_id: nil, type: nil, owned: false, link_table: nil, back_column: nil, link_column: nil, source_aliases: []
    raise ArgumentError, "Invalid type: #{ type.inspect }", caller unless ING::DBO::Type === type && Module === type
    nm = check_name name
    id = if from_id
      check_name from_id
    else
      "#{ uns(nm) }_ids".intern
    end
    tp = ING::DBO::List[type]
    tb = check_name(link_table || "#{ self.table }_#{ nm }")
    bc = check_name(back_column || "#{ self.short_name }_id")
    lc = check_name(link_column || "#{ type.short_name }_id")
    fld = ING::DBO::LinksField::new nm, id, tp, owned, tb, bc, lc, source_aliases
    self.define_method "#{ nm }" do
      instance_variable_get "@#{ nm }"
    end
    self.define_method "#{ id }" do
      v = instance_variable_get("@#{ nm }") || []
      v.map { |e| e.id }
    end
    self.define_method "#{ nm }=" do |value|
      v = fld.validate value
      instance_variable_set "@#{ nm }", v
    end
    self.define_method "#{ id }=" do |value|
      v = fld.validate_id value
      instance_variable_set "@#{ nm }", v
    end
    @fields ||= {}
    @fields[nm] = fld
  end

  # индексация управляется в ссылающейся таблице
  protected def backs name, from_id: nil, type: nil, owned: false, back_column: nil, source_aliases: []
    raise ArgumentError, "Invalid type: #{ type.inspect }", caller unless ING::DBO::Type === type && Module === type
    nm = check_name name
    id = if from_id
      check_name from_id
    else
      "#{ uns(nm) }_ids".intern
    end
    tp = ING::DBO::List[type]
    bc = check_name(back_column || "#{ self.short_name }_id")
    fld = ING::DBO::BacksField::new nm, id, tp, owned, bc, source_aliases
    self.define_method "#{ nm }" do
      instance_variable_get "@#{ nm }"
    end
    self.define_method "#{ id }" do
      v = instance_variable_get("@#{ nm }") || []
      v.map { |e| e.id }
    end
    self.define_method "#{ nm }=" do |value|
      v = fld.validate value
      instance_variable_set "@#{ nm }", v
    end
    self.define_method "#{ id }=" do |value|
      v = fld.validate_id value
      instance_variable_set "@#{ nm }", v
    end
    @fields ||= {}
    @fields[nm] = fld
  end

  public def fields with_super = true
    @fields ||= {}
    result = {}
    if with_super
      ancestors.reverse.each do |ancestor|
        if ancestor != self && ancestor.respond_to?(:fields)
          af = ancestor.fields false
          if Hash === af
            result.merge! af
          end
        end
      end
    end
    result.merge! @fields
    result
  end

  public def DDL
    cols = []
    keys = []
    refs = []
    inds = []
    lnks = []
    fields.each do |_, field|
      cs, ks, rs, is, ls = field.DDL self
      cols += cs
      keys += ks
      refs += rs
      inds += is
      lnks += ls
    end
    core_ddl = "CREATE TABLE #{ self.table } (\n" +
                cols.map { |c| "  #{ c }" }.join(",\n") + ",\n" +
                keys.map { |k| "CONSTRAINT #{ k }" }.join(",\n") + "\n" +
               ");"
    refs_ddl = refs.map { |r| "ALTER TABLE #{ self.table }\n  ADD CONSTRAINT #{ r };" }.join("\n")
    lnks_ddl = lnks.map { |l| "#{ l };" }.join("\n")
    inds_ddl = inds.map { |i| "CREATE INDEX #{ i };" }.join("\n")
    [ core_ddl, refs_ddl, lnks_ddl, inds_ddl ]
  end

  protected def register
    ING::DBO::DDL.register self
  end

  class << self

    def register cls
      @@classes ||= {}
      @@classes[cls] = true
    end

    def unregister cls
      @@classes ||= {}
      @@classes[cls] = false
    end

    def classes
      @@classes ||= {}
      @@classes.select { |_, v| v }.keys
    end

    def DDL
      core = []
      refs = []
      lnks = []
      inds = []
      classes.each do |cls|
        cr, rs, ls, is = cls.DDL
        core << cr if cr != ''
        refs << rs if rs != ''
        lnks << ls if ls != ''
        inds << is if is != ''
      end
      # pp [core, refs, lnks, inds]
      core.join("\n\n") + "\n\n\n" + refs.join("\n\n") + "\n\n\n" + lnks.join("\n\n") + "\n\n\n" + inds.join("\n\n")
    end

  end

end
