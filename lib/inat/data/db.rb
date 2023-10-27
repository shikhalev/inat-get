# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

require_relative '../app/globals'
require_relative 'ddl'

class DB

  def self.get_finalizer *dbs
    proc do
      dbs.each { |db| db.close }
    end
  end

  def initialize
    @config = G.config
    @directory = @config[:data][:directory]
    FileUtils.mkpath @directory
    @data = SQLite3::Database::open "#{@directory}/inat-cache.db"
    @data.encoding = 'UTF-8'
    @data.auto_vacuum = 1
    @data.results_as_hash = true
    @data.foreign_keys = true
    @data.execute_batch DDL.DDL
    ObjectSpace.define_finalizer self, self.class.get_finalizer(@data)
  end

  def execute query, *args
    @data.execute query, args
  end

  def transaction &block
    raise ArgumentError, "Block is required?", caller unless block_given?
    @data.transaction(&block)
  end

  class << self

    def instance
      @instance ||= DB::new
      @instance
    end

    def execute query, *args
      instance.execute query, *args
    end

    def transaction &block
      instance.transaction(&block)
    end

  end

end
