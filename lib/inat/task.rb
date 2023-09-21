# frozen_string_literal: true

require 'yaml'
require_relative 'utils/merge'
require_relative 'cache'

class Task

  using DeepMerge

  private def try_extensions base, *extensions
    extensions.each do |ext|
      file = base + ext
      return file if File.exists?(file)
    end
    return nil
  end

  private def find_files name
    name = name.to_s
    file = File.expand_path name
    down = file.downcase
    base = file
    flag = false
    if down.end_with?('.inat')
      base = file[0..-6]
    elsif down.end_with?('.rb')
      base = file[0..-4]
    elsif down.end_with?('.')
      base = file[0..-2]
      flag = true
    else
      flag = true
    end
    if flag
      file = try_extensions base, '', '.iNat', '.inat', '.INAT', '.rb', '.RB'
    end
    raise ArgumentError, "Task with name '#{name}' does not exist." if file.nil? || !File.exists?(file)

    conf = try_extensions base, '.yaml', '.YAML', '.yml', '.YML', '.conf', '.CONF', '.cfg', '.CFG'

    return {
      source: file,
      config: conf,
      basename: File.basename(base),
    }
  end

  attr_reader :name

  def initialize name, config, api
    @done = false
    @config = config
    @api = api
    files = find_files name
    @name = files[:basename]
    if files[:config]
      yaml = YAML.load_file files[:config]
      @config.deep_merge! yaml
    end
    @cache = Cache::new @config, @api
    # TODO: exception logging
    self.instance_eval "define_singleton_method :run do\nbegin\n" + File.read(files[:source]) + "\nrescue\nensure\n@done = true\nend\nend"
  end

  def done?
    @done
  end

  private def API
    @api
  end

  private def config
    @config
  end

  private def select **query
    #
  end

end
