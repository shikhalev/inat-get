# frozen_string_literal: true

require_relative 'globals'

# TODO: переделать на отдельный поток и очередь статусов. Ввести отдельно ключ, как идентификатор запроса, например.

module Status

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
      @mutex = Mutex::new
    end

    def status str
      @mutex.synchronize do
        key = G.current_task&.name&.intern
        name = ellipsis G.current_task&.name, 25
        @lines ||= {}
        @lines[key] = format("%25s", name) + " : #{ str }\e[0K\n"
        $stdout.print "=====\e[0K\n"
        @lines.each do |_, line|
          $stdout.print line
        end
        $stdout.print "-----\e[0K\n"
        $stdout.print "\e[#{ @lines.size + 2 }A\r"
      # @lines[key] ||= get_num
      # $stdout.printf "\e[#{ @lines[key] + 1 };0H%32s : %s\e[0K\e[H", name, str
      end
    end

  end

  private def status str
    self.class.status str
  end

end

Status::init
