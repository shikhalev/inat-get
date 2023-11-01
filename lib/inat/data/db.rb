# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

require_relative '../app/globals'
require_relative 'ddl'

class DB

  include LogDSL

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
    @mutex ||= Mutex::new
    @mutex.synchronize do
      last_time = Time::new
      # info "DB: query = #{ query } args = #{ args.inspect }"
      result = @data.execute query, args
      time_diff = Time::new - last_time
      # debug "DB OK: count = #{ Array === result && result.size || 'none' } time = #{ time_diff }"
      result
    end
  end

  def execute_batch query
    @mutex ||= Mutex::new
    @mutex.synchronize do
      last_time = Time::new
      # info "DB: batch = #{ query }"
      @data.execute_batch query
      time_diff = Time::new - last_time
      # debug "DB OK: time = #{ time_diff }"
    end
  end

  # def transaction &block
  #   raise ArgumentError, "Block is required?", caller unless block_given?
  #   @data.transaction(&block)
  # end

  class << self

    def instance
      @instance ||= DB::new
      @instance
    end

    def execute query, *args
      instance.execute query, *args
    end

    def execute_batch query
      instance.execute_batch query
    end

    # def transaction &block
    #   instance.transaction(&block)
    # end

  end

end
