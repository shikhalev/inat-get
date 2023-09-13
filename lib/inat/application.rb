# frozen_string_literal: true

require 'optparse'

class Application

  class << self

    def init
      @@application ||= new
      @@application
    end

    private :new
  end

  def initialize
  end

  def run
  end

end
