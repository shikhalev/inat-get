module INat

  class Application

    class << self

      private :new

      def get
        @@instance ||= new
        @@instance
      end

    end

    def initialize
      # TODO: implement
    end

    def run
      # TODO: implement
    end

  end

  class << self

    def application
      INat::Application.get
    end

  end

end
