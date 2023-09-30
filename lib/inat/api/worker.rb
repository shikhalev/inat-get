# frozen_string_literal: true

require_relative '../consts'

class INatWorker

  include Constants

  attr_reader :config

  def config
    @api.config
  end

  def initialize api
    @api = api
    @threads = config[:threads][:enable]
    if @threads
      @stop = false
      @queue = Queue::new
    end
  end

  def stop
    @stop = true
  end

  def << query
    if @threads
      @queue << query
    else
      query.execute
    end
  end

  def run
    if config[:threads][:enable]
      @thread = Thread::start do
        until @stop do
          query = @queue.pop
          if query
            query.execute
            sleep WORK_SLEEP
          else
            sleep WAIT_SLEEP
          end
        end
      end
    end
  end

end
