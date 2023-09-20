# frozen_string_literal: true

require 'date'
require 'yaml'
require 'logger'
require 'optparse'

require_relative './utils/merge'
require_relative './api'
require_relative './task'

class Application

  using DeepMerge

  class << self

    def init
      @@application ||= new
      @@application
    end

    private :new
  end

  EXE = File.basename $0
  NAME = File.basename $0, '.rb'
  CONFIG_PATH = File.expand_path "~/.config/#{ NAME }.yml"
  DATA_PATH = File.expand_path "~/.local/#{ NAME }/"

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
        tasks: 3,
        query_sleep: 0.1,
        worker_sleep: 1.0,
        main_sleep: 3.0,
      },
      config: [],
      output: {
        file: :default,
        directory: '.',
      },
      data: {
        update: :update,
        update_interval: '1d',
        cache: true,
        directory: DATA_PATH,
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
  # TODO:
  USAGE = "Usage: $ #{EXE} [options] ‹task[, ...]›"
  ABOUT = 'INat::Get — A toolset for fetching and processing data from iNaturalist.org.'

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
        when :'force-update'
          UpdateMode::FORCE
        when :'force-reload'
          UpdateMode::RELOAD
        when :default
          UpdateMode::DEFAULT
        when :'no-update'
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

      o.separator ''

      o.on '-h', '--help', 'Show this help and exit.' do
        puts ABOUT
        puts
        puts op.help
        exit 0
      end

      o.on '-?', '--usage', 'Show usage info and exit.' do
        puts op.help
        exit 0
      end

      o.on '--about', 'Show information about program and exit.' do
        puts ABOUT
        exit 0
      end

      o.on '--version', 'Show version information and exit.' do
        puts VERSION
        exit 0
      end

      o.separator ''

      o.on '-c', '--config FILE', String, 'Add config file over standard ("~/.config/‹appname›.yaml").' do |file|
        @config[:config] << file
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
        pp [file, file.class]
        if file == true || file.nil? || file.empty?
          @config[:log][:file] = :default
          @config[:log][:enable] = true
        elsif %w[no none null false].include?(file.downcase)
          @config[:log][:enable] = false
        else
          @config[:log][:file] = file
          @config[:log][:enable] = false
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

      o.on '-t', '--tasks COUNT', Integer, 'Limit for concurrent tasks count.' do |value|
        @config[:threads][:tasks] = value
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

      o.on '--no-update', '--offline', 'No update anyway. New datasets will be empty.' do
        @config[:data][:update] = UpdateMode::NO_UPDATE
      end

      o.on '-u', '--update MODE', UpdateMode, 'Rules for update datasets. Available values:',
                                              ' - "update" (or "default")',
                                              ' - "force" (or "force-update")',
                                              ' - "reload" (or "force-reload")',
                                              ' - "skip"',
                                              ' - "no" (or "no-update")' do |value|
        @config[:data][:update] = value
      end

      o.on '-U', '--update-interval VALUE', String, 'Interval for update.' do |value|
        @config[:data][:update_interval] = value
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

  private def init_api!
    @api = API::new @config
  end

  private def create_task task
    task = task.to_s
    if task.start_with?('@')
      file = task[1..-1]
      lines = File.readlines(file, chomp: true)
      lines.map { |l| create_task l }
    else
      Task::new task, @config, @api
    end
  end

  private def create_tasks!
    if @rest.empty?
      raise OptionParser::MissingArgument, "No tasks found."
    end
    @tasks = @rest.map { |t| create_task t }.flatten
  end

  def initialize
    setup_defaults!
    load_config!
    parse_command_line!
    load_other_configs!
    init_api!
    create_tasks!
  end

  private def run_tasks
    if @config[:threads][:enable]
      @pool = []
      limit = @config[:threads][:tasks]
      until @tasks.empty? && @pool.empty? do
        @pool.filter! { |t| !t.done? }
        while @pool.size < limit && !@tasks.empty? do
          task = @tasks.shift
          if task
            Thread::start task do |t|
              t.run
            end
            @pool << task
          end
        end
        sleep @config[:threads][:main_sleep]
      end
    else
      @tasks.each do |t|
        t.run
      end
    end
  end

  private def stop_worker
    @api.worker.stop
  end

  def run
    run_tasks
    stop_worker
  end

end
