# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

require_relative '../app/globals'
require_relative 'ddl'

class INat::DB

  include INat
  include INat::App
  include INat::App::Logger::DSL

  # @private
  def self.get_finalizer *dbs
    proc do
      dbs.each { |db| db.close }
    end
  end

  def initialize
    @mutex = Mutex::new
    @config = G.config
    @directory = @config[:data][:directory]
    FileUtils.mkpath @directory
    @data = SQLite3::Database::open "#{@directory}/inat-cache.db"
    @mutex.synchronize do
      @data.encoding = 'UTF-8'
      @data.auto_vacuum = 1
      @data.results_as_hash = true
      @data.foreign_keys = true
      @data.execute_batch Data::DDL.DDL
    end
    ObjectSpace.define_finalizer self, self.class.get_finalizer(@data)
  end

  def execute query, *args
    Status::status '[db]', '...'
    result = []
    @mutex.synchronize do
      last_time = Time::new
      info "DB: query = #{ query } args = #{ args.inspect }"
      result = @data.execute query, args
      time_diff = Time::new - last_time
      debug "DB OK: count = #{ Array === result && result.size || 'none' } time = #{ (time_diff * 1000000).to_i }ns"
    end
    Status::status '[db]', 'DONE'
    result
  end

  def execute_batch query
    Status::status '[db]', '...'
    @mutex.synchronize do
      last_time = Time::new
      info "DB: batch = #{ query }"
      @data.execute_batch "BEGIN TRANSACTION;\n" + query + "\nCOMMIT;\n"
      time_diff = Time::new - last_time
      debug "DB OK: time = #{ (time_diff * 1000000).to_i }ns"
    end
    Status::status '[db]', 'DONE'
  end

  # def transaction &block
  #   raise ArgumentError, "Block is required?", caller unless block_given?
  #   @data.transaction(&block)
  # end

  class << self

    private :new

    def instance
      @instance ||= new
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
