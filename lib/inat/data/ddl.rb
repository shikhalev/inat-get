# frozen_string_literal: true

# TODO: подумать и заменить константой, возможно

module INat::Data::DDL

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
