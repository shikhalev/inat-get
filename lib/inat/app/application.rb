# frozen_string_literal: true

require_relative 'config'
require_relative 'logging'
require_relative 'preamble'
require_relative 'globals'
require_relative 'task'

class Application

  include AppPreamble

  def logger
    G.logger
  end

  def initialize
    setup!
    G.config = @config.freeze
    G.logger = DualLogger::new self
  end

  private def tasks!
    @tasks = Queue::new
    @files.each do |file|
      @tasks.push Task::new(self, file)
    end
  end

  private def start!
    @threads = []
    count = [ @tasks.size, G.config[:threads][:tasks] ].min
    count.times do
      @threads << Thread.start do
        while !@tasks.empty?
          task = @tasks.pop
          task.execute
        end
      end
    end
    @threads.each { |th| th.join }
  end

  def run
    preamble!
    tasks!
    start!
  end

end
