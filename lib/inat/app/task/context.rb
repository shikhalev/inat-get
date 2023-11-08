# frozen_string_literal: true

require_relative 'dsl'

class Task::Context

  include Task::DSL

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
                "  rescue Exception => e\n" +
                "    error \"\#{e.inspect}\"\n" +
                "    debug \"\#{e.backtrace.join(\"\\n\\t\")}\"\n" +
                "  rescue\n" +
                "    error 'Unknown error!'\n" +
                "  end\n" +
                "  @done = true\n" +
                "end"
    self.instance_eval full_code
  end

end
