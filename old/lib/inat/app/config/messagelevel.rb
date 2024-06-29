# frozen_string_literal: true

require 'extra/enum'

module INat::App::Config; end

class INat::App::Config::MessageLevel < Enum

  item :TRACE, -1
  item :DEBUG,   data: 0
  item :INFO,    data: 1
  item :WARNING, data: 2
  item :ERROR,   data: 3
  item :FATAL,   data: 4
  item :UNKNOWN, data: 5

  item_alias :WARN => :WARNING

  def severity
    self.data
  end

  freeze
end
