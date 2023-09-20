# frozen_string_literal: true

module DataModel

  module Ext

    def field name, type: String, nullable: false, unique: false, index: false, reference: nil, reference_key: :id
      info = {
        type: type,
        nullable: nullable,
        unique: unique,
        index: index,
      }
      @fields ||= {}
      @fields[name] = info
      # TODO:
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

    def source url = nil
      @source = url if url
      @source
    end

  end

  def self.included mod
    mod.extend Ext
  end

  def update! **data
    # TODO:
    @stored = false
  end

  def fetch
    # TODO:
    @filled = true
  end

  def load
    # TODO:
    @filled = true
    @stored = true
  end

  def save
    # TODO:
    @stored = true
  end

  def filled?
    @filled ||= false
    @filled
  end

  def stored?
    @stored ||= false
    @stored
  end

end
