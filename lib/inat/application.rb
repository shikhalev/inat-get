# frozen_string_literal: true

require 'date'
require 'yaml'
require 'logger'
require 'optparse'

require_relative './utils/merge'

class Application

  using DeepMerge

  class << self

    def init
      @@application ||= new
      @@application
    end

    private :new
  end

  attr_reader :config

  private def setup_defaults!
    @config = {
      verbose: Logger::Severity::WARN,
      log: {
        level: Logger::Severity::INFO,
        enable: false,
        file: :default
      },
      threads: {
        enable: true,
        limit: 3,
      },
      config: [],
      output: {
        file: :default,
        directory: '.',
      },
      data: {
        update: :update,
        cache: true,
      },
    }
  end

  private def load_config_file! file, warn: true
    if File.exists?(file)
      yaml = YAML.load_file file
      @config.deep_merge! yaml
    else
      if warn
        # TODO: show warning
      end
    end
  end

  EXE = File.basename $0
  NAME = File.basename $0, '.rb'
  CONFIG_PATH = File.expand_path "~/.config/#{ NAME }.yml"

  private def load_config!
    load_config_file! CONFIG_PATH, warn: false
  end

  module UpdateMode
    UPDATE = :update
    FORCE = :force
    RELOAD = :reload
    SKIP = :skip
    NO_UPDATE = :no
    DEFAULT = UPDATE
  end

  VERSION = '0.1.1'
  LICENSE = 'GNU General Public License version 3.0 (GPLv3)'
  HOMEPAGE = 'http://github.com/shikhalev/inat-get'
  AUTHOR  = 'Ivan Shikhalev <shikhalev@gmail.com>'
  USAGE = ''
  ABOUT = ''

  private_constant :USAGE, :ABOUT

  private def parse_command_line!
    op = OptionParser::new USAGE do |o|

      o.accept Logger::Severity do |key|
        k = key.downcase.intern
        case k
        when :fatal
          Logger::Severity::FATAL
        when :error
          Logger::Severity::ERROR
        when :warn, :warning
          Logger::Severity::WARN
        when :info
          Logger::Severity::INFO
        when :debug
          Logger::Severity::DEBUG
        else
          raise OptionParser::InvalidArgument, "'#{key}' is not a valid log level."
        end
      end

      o.accept UpdateMode do |mode|
        m = mode.downcase.intern
        case m
        when *%i[update force reload skip no]
          m
        when :default
          UpdateMode::DEFAULT
        when :no_update
          UpdateMode::NO_UPDATE
        else
          raise OptionParser::InvalidArgument, "'#{mode}' is not a valid update mode."
        end
      end

      o.accept Date do |value|
        begin
          Date::parse value
        rescue
          raise OptionParser::InvalidArgument, "'#{value}' is not a valid date."
        end
      end

      o.on '-h', '--help', 'Show this help and exit.' do
        puts ABOUT
        puts
        puts op.help
        # exit 0
      end

      o.on '-?', '--usage', 'Show usage info and exit.' do
        puts op.help
        # exit 0
      end

      o.on '--about', 'Show information about program and exit.' do
        puts ABOUT
        # exit 0
      end

      o.on '--version', 'Show version information and exit.' do
        puts VERSION
        # exit 0
      end

      o.separator ''

      o.on '-c', '--config FILE', String, 'Add config file over standard ("~/.config/‹appname›.yaml").' do |file|
        @config[:config] << file
        # TODO: load config
      end

      o.separator ''

      o.on '--verbose-level LEVEL', Logger::Severity, 'Log level for STDERR.' do |level|
        @config[:verbose] = level
      end

      o.on '-v', '--verbose', 'Set verbose level to INFO.' do
        @config[:verbose] = :info
      end

      o.on '--log-level LEVEL', Logger::Severity, 'Log level for log file.' do |level|
        @config[:log][:level] = level
      end

      o.on '-l', '--log [FILE]', String, 'Enable logging to file and set log filename.', 'Default is "./‹task_name›.log".' do |file|
        if file.nil? || file.empty?
          @config[:log][:file] = true
        elsif %w[no none null false].include?(file.downcase)
          @config[:log][:file] = false
        else
          @config[:log][:file] = file
        end
      end

      o.on '--log-file FILE', String, 'Set log filename without enabling/disabling file logging.' do |file|
        if %w[no none null false].include?(file.downcase)
          @config[:log][:file] = false
        else
          @config[:log][:file] = file
        end
      end

      o.separator ''

      o.on '-1', '--no-threads', "Disable multithread support." do
        @config[:threads][:enable] = false
      end

      o.on '-t', '--threads COUNT', Integer, 'Limit for concurrent threads count.' do |value|
        @config[:threads][:limit] = value
      end

      o.separator ''

      o.on '-o', '--output PATH', String, 'Directory for output files. Default is current directory.' do |path|
        @config[:output][:directory] = path
      end

      o.separator ''

      o.on '-f', '--force-update', 'Force dataset update.' do
        @config[:data][:update] = UpdateMode::FORCE
      end

      o.on '-F', '--force-reload', 'Force dataset reload.' do
        @config[:data][:update] = UpdateMode::RELOAD
      end

      o.on '--skip-update', 'Skip dataset update. Only new datasets will fetched from API.' do
        @config[:data][:update] = UpdateMode::SKIP
      end

      o.on '--no-update', 'No update anyway. New datasets will be empty.' do
        @config[:data][:update] = UpdateMode::NO_UPDATE
      end

      o.on '-u', '--update MODE', UpdateMode, 'Rules for update datasets.' do |value|
        @config[:data][:update] = value
      end

      o.on '--no-cache', 'Disable caching datasets.' do
        @config[:data][:cache] = false
      end

    end

    @rest = op.parse ARGV
  end

  private def load_other_configs!
    @config[:config].each do |cfg|
      load_config_file! cfg
    end
  end

  def initialize
    setup_defaults!
    load_config!
    parse_command_line!
    load_other_configs!
  end

  private def start_worker
  end

  private def start_tasks
  end

  private def wait_tasks
  end

  private def stop_worker
  end

  def run
    start_worker
    start_tasks
    wait_tasks
    stop_worker
  end

end
