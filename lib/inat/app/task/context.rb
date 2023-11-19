# frozen_string_literal: true

require_relative 'dsl'
require_relative '../../report/table'

class Task::Context

  include Task::DSL
  include TableDSL

  attr_accessor :name

  def config
    @task.config
  end

  def logger
    @task.logger
  end

  def done?
    @done
  end

  def initialize task, name, path
    @task = task
    @name = name
    @done = false
    source_code = File.readlines(path).map { |line| "    #{line}" }.join('')
    full_code = "define_singleton_method :execute do\n" +
                "  begin\n" +
                "    #{source_code}\n" +
                "    Status::status nil, 'DONE'\n" +
                "  rescue Exception => e\n" +
                "    error \"\#{e.inspect}\"\n" +
                "    error \"\#{e.backtrace.join(\"\\n\\t\")}\"\n" +
                "    Status::status nil, 'ERROR : ' + e.inspect\n" +
                "  rescue\n" +
                "    error 'Unknown error!'\n" +
                "    Status::status nil, 'ERROR'\n" +
                "  end\n" +
                "  @done = true\n" +
                "end"
    self.instance_eval full_code
  end

end
