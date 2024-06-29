# frozen_string_literal: true

# TODO: подумать и заменить константой, возможно

class INat::Data::DDL

  def initialize
    @models = []
  end

  def <<(model)
    @models << model
  end

  def DDL
    @models.map(&:DDL).join("\n")
  end

  class << self

    private :new

    def instance
      @instance ||= new
    end

    def <<(model)
      instance << model
    end

    def DDL
      instance.DDL
    end

  end

end
