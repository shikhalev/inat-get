# frozen_string_literal: true

require 'uri'
require 'net/http'
require_relative 'utils/merge'

class API

  using DeepMerge

  class Worker

    attr_reader :thread

    def initialize api
      @config = api.config
      @threads = @config[:threads][:enable]
      @queue = []
      @stop_flag = false
    end

    def run
      if @threads
        @thread = Thread::start do
          until @stop_flag do
            first = @queue.shift
            if first
              first.execute
              sleep @config[:threads][:worker_sleep]
            else
              sleep @config[:threads][:query_sleep]
            end
          end
        end
      end
    end

    def stop
      @stop_flag = true
    end

    def << query
      if @threads
        @queue << query
      else
        query.execute
      end
    end

  end

  class Query

    class Status

      ENQUEUED = :ENQUEUED
      WORKED = :WORKED
      COMPLETED = :COMPLETED
      FAILED = :FAILED

    end

    USER_AGENT = 'INat::Get client'
    OBSERVATIONS_URL = 'https://api.inaturalist.org/v1/observations'
    MAX_PER_PAGE = 200

    attr_reader :status
    attr_reader :results

    private def get_uri **query
      qss = []
      @query.each do |key, value|
        if Array === value
          value = value.map { |v| v.to_s }.join(',')
        end
        qss << "#{key}=#{value}"
      end
      qs = qss.join '&'
      URI("#{OBSERVATIONS_URL}?#{qs}")
    end

    def initialize api, **query
      @config = api.config
      @worker = api.worker
      @query = query
      @query[:per_page] ||= MAX_PER_PAGE
      @query[:order_by] = :id
      @query[:order] = :asc
      @uri = get_uri **query
      @results = []
      @status = Status::ENQUEUED
      @worker << self
    end

    private def fetch http, uri
      rq = Net::HTTP::Get::new uri
      rq['User-Agent'] = @config[:user_agent] || USER_AGENT
      rs = http.request rq
      if Net::HTTPSuccess === rs
        result = JSON.parse rs.body
        @results += result['results']
        total = result['total_results']
        paged = result['per_page']
        if total > paged
          above = result['results'].map { |o| o.id }.max
          query = @query.deep_clone
          query[:id_above] = above
          sleep @config[:threads][:worker_sleep]
          fetch http, get_uri(**query)
        end
      else
        # TODO: log
        @status = Status::FAILED
      end
    end

    def execute
      begin
        @status = Status::WORKED
        Net::HTTP::start @uri.host, @uri.port, use_ssl: true do |http|
          fetch http, @uri
        end
        @status = Status::COMPLETED if @status == Status::WORKED
      rescue Exception => e
        # TODO: log
        @status = Status::FAILED
      rescue
        # TODO: log
        @status = Status::FAILED
      end
    end

    def wait
      until [ Status::COMPLETED, Status::FAILED ].include?(@status) do
        sleep @config[:threads][:query_sleep]
      end
      @status == Status::COMPLETED
    end

  end

  attr_reader :config
  attr_reader :worker

  def initialize config
    @config = config
    @worker = Worker::new self
    @worker.run
  end

  def select **query
    Query::new(self, **query).wait
  end

end
