# frozen_string_literal: true

require_relative 'globals'

# TODO: переделать на отдельный поток и очередь статусов. Ввести отдельно ключ, как идентификатор запроса, например.

module INat::App::Status

  class << self

    private def ellipsis src, len
      return '' unless String === src
      if src.length <= len
        src
      else
        src[.. len - 4] + '...'
      end
    end

    # private def get_num
    #   @num ||= 0
    #   @num += 1
    #   @num
    # end

    def init
      @lines = {}
      @mutex = Mutex::new
      @shift = 0
    end

    def up
      $stderr.print "\e[#{ @shift }A\r" if @shift > 0
    end

    def out
      $stderr.print "\e[0K\n"
      @lines.each do |key, value|
        $stderr.print "#{ value }\e[0K\n"
      end
      $stderr.print "\e[0K\n"
      @shift = @lines.size + 2
    end

    def wrap
      @mutex.synchronize do
        up
        yield
        out
      end
    end

    def status key, value
      task = ellipsis G.current_task&.name, 16
      key = task if key == nil
      line = format("%16s | %s", key.to_s, value)
      @mutex.synchronize do
        @lines ||= {}
        @lines[key] = line
        up
        out
      end
    end

  end

  private def status str
    self.class.status str
  end

end

INat::App::Status::init
G.status = INat::App::Status
