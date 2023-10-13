# frozen_string_literal: true

module Condition

  IS_NULL = lambda { |value| value.nil? }
  IS_NOT_NULL = lambda { |value| !value.nil? }

  class LESS_OR_NULL

    attr_reader :value

    def initialize value
      @value = value
    end

    def === value
      value.nil? || value < @value
    end

  end

  class LESS

    attr_reader :value

    def initialize value
      @value = value
    end

    def === value
      value < @value
    end

  end

  class GREATER

    attr_reader :value

    def initialize value
      @value = value
    end

    def === value
      value > @value
    end

  end

end
