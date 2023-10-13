# frozen_string_literal: true

class Cache

  attr_reader :config, :logger

  def config
    @application.config
  end

  def logger
    @application.logger
  end

  def initialize application
    @application = application
  end

  def select **params
    # TODO: implement
  end

end
