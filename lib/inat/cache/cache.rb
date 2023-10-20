# frozen_string_literal: true

class Cache

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
    # NEED: implement
  end

end
