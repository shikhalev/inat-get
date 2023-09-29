# frozen_string_literal: true

require_relative 'query'
require_relative 'worker'

class INatAPI

  attr_reader :config

  def config
    @application.config
  end

  def initialize application
    @application = application
    @worker = Worker::new self
    @worker.run
  end

  def query task, path, **params
    query = INatQuery::new task, self, path, **params
    @worker << query
    query.results
  end

end
