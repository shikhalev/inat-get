# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

require_relative './entity/models/observation'
require_relative './entity/ddl'

class DB

  def self.get_finalizer *dbs
    proc do
      dbs.each { |db| db.close }
    end
  end

  def initialize config
    @config = config
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
    @data.execute query, *args
  end

end
