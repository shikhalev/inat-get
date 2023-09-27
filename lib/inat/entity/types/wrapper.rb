# frozen_string_literal: true

require 'json'

# Это такая затычка для произвольных данных, хранимых как JSON

class Wrapper

  class << self

    def make data, cache: nil, from: :API
      return nil if data.nil?
      data = JSON.parse(data) if from == :DB
      self.new data
    end

    def db_type
      :TEXT
    end

  end

  attr_reader :data

  def initialize data
    @data = data
  end

  def to_db
    JSON.stringify(@data)
  end

end
