# frozen_string_literal: true

require 'fileutils'
require 'sqlite3'

class DB

  DATA_INIT = <<-SQL
  SQL

  SETS_INIT = <<-SQL
    CREATE TABLE IF NOT EXISTS datasets (
      query_data TEXT NOT NULL PRIMARY KEY,
      query_time INTEGER NOT NULL
    );
    CREATE INDEX IF NOT EXISTS ix_datasets_time ON datasets (time) ASC;
  SQL

  def initialize config
    @config = config
    @directory = @config[:data][:directory]
    FileUtils.mkpath @directory
    @data = SQLite3::Database::open "#{@directory}/inat-cache.db"
    @data.encoding = 'UTF-8'
    @data.auto_vacuum = 1
    @data.results_as_hash = true
    @data.foreign_keys = true
    @data.execute DATA_INIT
    @sets = SQLite3::Database::open "#{@directory}/inat-cache-sets.db"
    @sets.encoding = 'UTF-8'
    @data.auto_vacuum = 1
    @sets.results_as_hash = true
    @sets.execute SETS_INIT
    ObjectSpace.define_finalizer self, proc do
      @data.close if @data
      @sets.close if @sets
    end
  end

  def clean_query_times last_time
    @sets.execute 'DELETE FROM datasets WHERE query_time > ?;', last_time
  end

  def get_query_times
    @sets.execute 'SELECT query_data, query_time FROM datasets;'
  end

  def set_query_time data, time
    @sets.execute 'INSERT OR REPLACE INTO datasets (query_data, query_time) VALUES (?, ?);', data, time
  end

  def execute query, *args
    @data.execute query, *args
  end

  def select **query
    # TODO:
  end

end
