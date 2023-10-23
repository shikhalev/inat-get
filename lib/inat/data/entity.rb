# frozen_string_literal: true

require_relative 'model'
require_relative 'ddl'

class Entity < Model

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
      result = []
      # NEED: implement
      result
    end

    def parse src
      return nil if src == nil
      raise TypeError, "Source must be a Hash!" unless Hash === src
      id = src[:id] || src['id']
      raise ArgumentError, "Source must have an Integer 'id' value!" unless Integer === id
      entity = self.get id
      entity.update do
        fields = self.fields
        src.each do |key, value|
          key = key.intern if String === key
          field = fields[key]
          raise ArgumentError, "Field not found: '#{ key }'!" unless field
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

end
