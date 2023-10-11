# frozen_string_literal: true

require 'optparse'

require_relative 'info'
require_relative 'messagelevel'
require_relative 'updatemode'

class Application

  include AppInfo

  DEFAULTS = {
    threads: {
      enable: true,
      tasks: 3,
    },
    data: {
      cache: true,
      update: UpdateMode::UPDATE,
    },
  }

  CONFIG_FILE = File.expand_path "~/.config/#{ NAME }.yml"

  private def parse_args!
    options = {}
    opts = OptionParser::new USAGE do |o|

      o.accept UpdateMode do |mode|
        UpdateMode::parse mode
      end

      o.accept MessageLevel do |level|
        MessageLevel::parse level
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
        options[:threads][:enable] = false
      end

      o.on '-t', '--tasks NUMBER', Integer, 'Limit number of concurrent tasks.' do |value|
        options[:threads][:tasks] = value
      end

      o.separator ''
      o.separator "\e[1mCache Control:\e[0m"

      o.on '-u', '--update MODE', UpdateMode, "Update mode:", "  'default' (or 'update')",
                                                              "  'force-update' (or 'force')",
                                                              "  'force-reload' (or 'reload')",
                                                              "  'skip-existing' (or 'minimal')",
                                                              "  'no-update' (or 'offline')" do |value|
        options[:data][:update] = value
      end

      o.on '-f', '--force-update', 'Force update.' do
        options[:data][:update] = UpdateMode::FORCE
      end

      o.on '-F', '--force-reload', '--reload', 'Force reload.' do
        options[:data][:update] = UpdateMode::RELOAD
      end

      o.on '--min-update', '--skip-existing', 'Skip updating if exist.' do
        options[:data][:update] = UpdateMode::MINIMAL
      end

      o.on '-n', '--offline', '--no-update', 'No updating.' do
        options[:data][:update] = UpdateMode::OFFLINE
      end

      o.separator ''

      o.on '-i', '--direct', '--no-cache', 'Do not cache.' do
        options[:data][:cache] = false
      end

      o.separator ''

      o.on '--clean-requests', 'Clean outdated requests in data cache.' do
        # TODO: implement
      end

      o.on '--clean-observations', 'Clean observations without request in data cache.' do
        # TODO: implement
      end

      o.on '--clean-orphans', 'Clean orphan objects in data cache.' do
        # TODO: implement
      end

      o.on '--clean-all', 'Clean data cache.' do
        # TODO: implement
      end

      o.separator ''
      o.separator "\e[1mAPI Parameters:\e[0m"

      o.on '-A', '--api-root URI', String, 'API root' do |value|
        # TODO: implement
      end

      o.on '-L', '--locale LOCALE', String, 'Set the locale.' do
        # TODO: implement
      end

      o.on '-P', '--preferred-place ID', Integer, 'Preferred place for API.' do |value|
        # TODO: implement
      end

      o.separator ''
      o.separator "\e[1mLogging Control:\e[0m"

      o.on '--verbose-level LEVEL', MessageLevel, 'Set the logging level for $STDERR.', "  'fatal'",
                                                                                            "  'error'",
                                                                                            "  'warn' (or 'warning')",
                                                                                            "  'info'",
                                                                                            "  'debug'",
                                                                                            "  'none' for disabling." do |value|
        # TODO: implement
      end

      o.on '-v', '--verbose', 'Set verbose level to INFO.' do |value|
        # TODO: implement
      end

      o.on '--log-level LEVEL', MessageLevel, 'Set the logging level for file log' do |value|
        # TODO: implement
      end

      o.on '--log-file FILE', String, 'File name for log.' do |value|
        # TODO: implement
      end

      o.on '-l', '--log [FILE]', String, 'Enable logging to file. If file is not specified ./‹task›.log used.',
                                         "  'none', 'no' or 'false' to disabling." do |value|
        # TODO: implement
      end

      o.separator ''

      o.separator "\e[1mFile Arguments:\e[0m"
      o.separator "\t‹task[, ...]›\t\t     One or more names of task files.\n" +
                  "\t\t\t\t     If name has not extension try to read '‹task›' than '‹task›.inat' than '‹task›.rb'."

    end
    files = opts.parse ARGV
    [ options, files ]
  end

  private def setup!
    @config = DEFAULTS
    options, @files = parse_args!
    config_file = options[:config_file] || CONFIG_FILE
  end

  attr_reader :config

end
