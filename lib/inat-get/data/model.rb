
class Model

  class Index

    attr_reader :kind, :fields, :model

    def initialize model, kind, *fields
      raise ArgumentError, "Invalid model: #{ model.inspect }", caller unless Class === model && Model > model
      knd = kind.downcase.intern
      knd = :primary if knd == :primary_key
      raise ArgumentError, "Invalid index kind: #{ kind.inspect }", caller unless [ :primary, :unique, :index ].include?(knd)
      @kind = knd
      @fields = fields
      @model = model
    end

    private def f_list
      fields.map { |f| f.to_s }.join(', ')
    end

    private def f_name
      fields.map { |f| f.to_s }.join('_')
    end

    PREFS = { primary: 'pk', unique: 'uq', index: 'ix' }
    CONSS = { primary: 'PRIMARY KEY', unique: 'UNIQUE' }

    private_constant :PREFS, :CONSS

    def index?
      @kind == :index
    end

    def constraint?
      [ :primary, :unique ].include? @kind
    end

    def name
      "#{ PREFS[@kind] }_#{ @model.table }_#{ f_name }"
    end

    def index
      if index?
        "#{ name } ON (#{ f_list })"
      else
        nil
      end
    end

    def constraint
      if constraint?
        "#{ name } #{ CONSS[@kind] } (#{ f_list })"
      else
        nil
      end
    end

  end

  class Field

    def initialize name, type, required: false, aliases: []
      # TODO: implement
    end

  end

  private_constant :Index, :Field

  class << self

    def table name = nil
      @table ||= name if name
      @table
    end

    def from_json src
      # TODO: implement
    end

    def from_row src
      # TODO: implement
    end

    def field name, type, options # FIXME: options
      # TODO: implement
    end

    def links name, type, options # FIXME: options
      # TODO: implement
    end

    def backs name, type, options # FIXME: options
      # TODO: implement
    end

    private :field, :links, :backs

    def primary_key *fields
      @indices ||= {}
      @indices[:primary] = Index.new(self, :primary, *fields) unless fields.empty?
      @indices[:primary]
    end

    def unique *fields
      @indices ||= {}
      @indices[:unique] ||= []
      unless fields.empty?
        result = Index.new(self, :unique, *fields)
        @indices[:unique] << result
        result
      else
        raise ArgumentError, "Empty field list", caller
      end
    end

    def index *fields
      @indices ||= {}
      @indices[:index] ||= []
      unless fields.empty?
        result = Index.new(self, :index, *fields)
        @indices[:index] << result
        result
      else
        raise ArgumentError, "Empty field list", caller
      end
    end

    def constraints
      @indices ||= {}
      [ @indices[:primary], @indices[:unique] ].flatten.compact
    end

    def indices
      @indices ||= {}
      @indices[:index] ||= []
      @indices[:index]
    end

  end

  def to_json **opts
    # TODO: implement
  end

  def to_row
    # TODO: implement
  end

end
