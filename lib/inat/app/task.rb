# frozen_string_literal: true

require_relative 'globals'
require_relative 'task/context'

class Task

  CHECK_LIST = %w[ . .inat .rb ]
  FILE_CHECK_LIST = %w[ .inat .iNat .INat .INAT .rb .RB ]

  private_constant :CHECK_LIST, :FILE_CHECK_LIST

  private def existing path
    if File.exist?(path)
      path
    else
      nil
    end
  end

  private def try_extensions base, *extensions
    FILE_CHECK_LIST.each do |exception|
      path = base + exception
      return path if File.exist?(path)
    end
    return nil
  end

  private def name_complete? source
    s = source.downcase
    CHECK_LIST.each do |check|
      return true if s.end_with?(check)
    end
    return false
  end

  private def get_names source
    path = File.expand_path source
    basename = File.basename(source, '.*')
    return [ basename, existing(path) ] if name_complete?(source)
    base = path + '/' + basename
    name = try_extensions base, *FILE_CHECK_LIST
    return [ basename, name ]
  end

  def config
    @application.config
  end

  def logger
    @application.logger
  end

  def name
    @context&.name
  end

  def done?
    @context&.done?
  end

  def initialize application, source
    @application = application
    @basename, @path = get_names source
    raise ArgumentError, "File not found: #{source}!" if @path.nil?
    @context = Task::Context::new self, @basename, @path
  end

  def execute
    G.current_task = self
    @context.execute
  end

end
