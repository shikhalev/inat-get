# frozen_string_literal: true

require 'yaml'
require 'optparse'

require_relative '../utils/deep'
require_relative '../../extra/period'
require_relative 'info'
require_relative 'config/messagelevel'
require_relative 'config/updatemode'
require_relative 'config/shiftage'

class Application

  include AppInfo

  API_DEFAULT = 'https://api.inaturalist.org/v1/'
  DEFAULT_LOG = "./#{ NAME }.log"

  DEFAULTS = {
    threads: {
      enable: true,
      tasks: 3,
    },
    data: {
      cache: true,
      directory: File.expand_path("~/.cache/#{ NAME }/"),
      update: UpdateMode::UPDATE,
      update_period: Period::DAY,
      outdate_period: Period::WEEK,
    },
    verbose: MessageLevel::ERROR,
    log: {
      enable: false,
      file: DEFAULT_LOG,
      level: MessageLevel::WARNING,
      shift: {
        age: nil,
        size: nil,
      },
    },
    api: {
      root: API_DEFAULT,
      locale: nil,
      preferred_place_id: nil,
      open_timeout: nil,
      read_timeout: nil,
    },
    preamble: [],
  }

  CONFIG_FILE = File.expand_path "~/.config/#{ NAME }.yml"

  private def parse_files files
    files.map do |file|
      if file.start_with?('@')
        list = file[1..]
        File.readlines(list, chomp: true).filter { |l| !l.empty? }
      else
        file
      end
    end.flatten
  end

  private def parse_args!
    options = {}
    opts = OptionParser::new USAGE do |o|

      o.accept UpdateMode do |mode|
        UpdateMode::parse mode, case_sensitive: false
      end

      o.accept MessageLevel do |level|
        MessageLevel::parse level, case_sensitive: false
      end

      o.accept ShiftAge do |shift_age|
        ShiftAge::parse shift_age
      end

      o.accept Period do |period|
        Period::parse period
      end

      o.separator ''
      o.separator "\e[1mInformation:\e[0m"

      o.on '-h', '--help', 'Show help and exit.' do
        puts ABOUT
        puts
        puts opts.help
        exit 0
      end

      o.on '-?', '--usage', 'Show short help and exit.' do
        puts opts.help
        exit 0
      end

      o.on '--about', 'Show program info and exit.' do
        puts ABOUT
        exit 0
      end

      o.on '--version', 'Show version and exit.' do
        puts VERSION
        exit 0
      end

      o.separator ''
      o.separator "\e[1mConfiguration:\e[0m"

      o.on '-c', '--config FILE', String, "Configuration file instead standard (~/.config/#{ NAME }.yml)." do |value|
        options[:config_file] = value
      end

      o.separator ''
      o.separator "\e[1mFlow Control:\e[0m"

      o.on '-1', '--no-threads', 'Disable threads.' do
        options[:threads] ||= {}
        options[:threads][:enable] = false
      end

      o.on '-t', '--tasks NUMBER', Integer, 'Limit number of concurrent tasks.' do |value|
        options[:threads] ||= {}
        options[:threads][:tasks] = value
      end

      o.separator ''
      o.separator "\e[1mCache Control:\e[0m"

      o.on '-u', '--update MODE', UpdateMode, "Update mode:", "  'default' (or 'update')",
                                                              "  'force-update' (or 'force')",
                                                              "  'force-reload' (or 'reload')",
                                                              "  'skip-existing' (or 'minimal')",
                                                              "  'no-update' (or 'offline')" do |value|
        options[:data] ||= {}
        options[:data][:update] = value
      end

      o.on '-f', '--force-update', 'Force update.' do
        options[:data] ||= {}
        options[:data][:update] = UpdateMode::FORCE
      end

      o.on '-F', '--force-reload', '--reload', 'Force reload.' do
        options[:data] ||= {}
        options[:data][:update] = UpdateMode::RELOAD
      end

      o.on '--skip-existing', 'Skip updating if exist.' do
        options[:data] ||= {}
        options[:data][:update] = UpdateMode::MINIMAL
      end

      o.on '-n', '--offline', '--no-update', 'No updating.' do
        options[:data] ||= {}
        options[:data][:update] = UpdateMode::OFFLINE
      end

      o.separator ''

      o.on '--update-period PERIOD', Period, 'Update period.' do |value|
        options[:data] ||= {}
        options[:data][:update_period] = value
      end

      o.on '--obsolete-period PERIOD', Period, 'Obsolete period.' do |value|
        options[:data] ||= {}
        options[:data][:obsolete_period] = value
      end

      o.on '--cache-directory PATH', String, 'Cache directory path.' do |value|
        options[:data] ||= {}
        options[:data][:directory] = value
      end

      o.separator ''

      o.on '--clean-requests', 'Clean outdated requests in data cache.' do
        options[:preamble] << :clean_requests
      end

      o.on '--clean-observations', 'Clean observations without request in data cache.' do
        options[:preamble] << :clean_observations
      end

      o.on '--clean-orphans', 'Clean orphan objects in data cache.' do
        options[:preamble] << :clean_orphans
      end

      o.on '--clean-all', 'Clean data cache.' do
        options[:preamble] << :clean_all
      end

      o.separator ''
      o.separator "\e[1mAPI Parameters:\e[0m"

      o.on '-A', '--api-root URI', String, 'API root' do |value|
        options[:api] ||= {}
        options[:api][:root] = value
      end

      o.on '-L', '--locale LOCALE', String, 'Set the locale.' do |value|
        value = nil if value.downcase == 'none'
        options[:api] ||= {}
        options[:api][:locale] = value
      end

      o.on '-P', '--preferred-place ID', Integer, 'Preferred place for API.' do |value|
        value = nil if value == 0
        options[:api] ||= {}
        options[:api][:preferred_place_id] = value
      end

      o.separator ''
      o.separator "\e[1mLogging Control:\e[0m"

      o.on '--verbose-level LEVEL', MessageLevel, 'Set the logging level for $STDERR.', "  'fatal'",
                                                                                            "  'error'",
                                                                                            "  'warn' (or 'warning')",
                                                                                            "  'info'",
                                                                                            "  'debug'" do |value|
        options[:verbose] = value
      end

      o.on '-v', '--verbose', 'Set verbose level to INFO.' do
        options[:verbose] = MessageLevel::INFO
      end

      o.on '--log-level LEVEL', MessageLevel, 'Set the logging level for file log' do |value|
        options[:log] ||= {}
        options[:log][:level] = value
      end

      o.on '--log-file FILE', String, 'File name for log.' do |value|
        value = DEFAULT_LOG if /^default$/i === value
        options[:log] ||= {}
        options[:log][:file] = value
      end

      o.on '-l', '--log [FILE]', String, "Enable logging to file. If file is not specified './#{ NAME }.log' used.",
                                         "  'none', 'no' or 'false' to disabling." do |value|
        options[:log] ||= {}
        case value
        when nil, /^(true|yes|default)$/i
          options[:log][:enable] = true
          options[:log][:file] = DEFAULT_LOG
        when /^(false|no|none)$/i
          options[:log][:enable] = false
          options[:log][:file] = DEFAULT_LOG
        else
          options[:log][:enable] = true
          options[:log][:file] = value.to_s
        end
      end

      o.on '--log-shift-age AGE', ShiftAge, 'Log file shift age.' do |value|
        value = nil if value == 0
        options[:log] ||= {}
        options[:log][:shift] ||= {}
        options[:log][:shift][:age] = value
      end

      o.on '--log-shift-size SIZE', Integer, 'Log file shift size.' do |value|
        value = nil if value == 0
        options[:log] ||= {}
        options[:log][:shift] ||= {}
        options[:log][:shift][:size] = value
      end

      o.separator ''

      o.separator "\e[1mFile Arguments:\e[0m"
      o.separator "\t‹task[, ...]›\t\t     One or more names of task files.\n" +
                  "\t\t\t\t     If name has not extension try to read '‹task›' than '‹task›.inat' than '‹task›.rb'."

    end
    files = parse_files(opts.parse(ARGV))
    [ options, files ]
  end

  private def setup!
    @config = DEFAULTS
    options, @files = parse_args!
    config_file = options[:config_file] || CONFIG_FILE
    @config.deep_merge! YAML.load_file(config_file, symbolize_names: true, freeze: true) if File.exist?(config_file)
    @config.deep_merge! options
    @config[:verbose] = MessageLevel::parse @config[:verbose]
    @config[:log][:level] = MessageLevel::parse @config[:log][:level]
  end

  attr_reader :config

end
