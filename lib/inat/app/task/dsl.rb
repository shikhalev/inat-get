# frozen_string_literal: true

class Task; end

module Task::DSL

  private def select **params
    # TODO: implement
  end

  private def echo msg, level: :INFO
    # TODO: implement
  end

  private def fatal msg
    echo msg, level: FATAL
    raise "Fatal: #{msg}"
  end

  private def error msg, fatal: false
    if fatal
      echo msg, level: :FATAL
      raise "Fatal: #{msg}"
    else
      echo msg, level: :ERROR
    end
  end

  private def warning msg
    echo msg, level: :WARNING
  end

  private def info msg
    echo msg, level: :INFO
  end

  private def debug msg
    echo msg, level: :DEBUG
  end

end
