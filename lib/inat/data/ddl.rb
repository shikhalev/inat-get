# frozen_string_literal: true

module DDL

  class << self

    def << model
      @models ||= []
      @models << model
    end

    def DDL
      @models.map(&:DDL).join("\n")
    end

  end

end
