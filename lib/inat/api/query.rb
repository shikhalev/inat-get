# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

require_relative '../consts'

class INatQuery

  include Constants

  STATUS_ENQUEUED = :ENQUEUED
  STATUS_WORKING = :WORKING
  STATUS_COMPLETED = :COMPLETED
  STATUS_FAILED = :FAILED

  attr_reader :config

  attr_reader :path, :params

  attr_reader :status

  def initialize task, api, path, *ids, **params
    @task = task
    @api = api
    @config = api.config.merge task.config
    @path = path
    @ids = ids
    @params = params
    @status = STATUS_ENQUEUED
    @results = []
  end

  def results
    until [ STATUS_COMPLETED, STATUS_FAILED ].include?(@status) do
      sleep WAIT_SLEEP
    end
    @results
  end

  private def make_uri **append
    uri = "#{ config[:http][:api_root] }#{ @path }"
    uri += "/#{ ids.map(&:to_s).join(',') }" unless @ids.empty?
    params = @params.merge append
    unless params.empty?
      params.merge!({ order: :asc, order_by: :id, per_page: 200 })
      params[:locale] = config[:http][:locale] if config[:http][:locale]
      params[:preferred_place_id] = config[:http][:preferred_place_id] if config[:http][:preferred_place_id]
      searches = []
      params.each do |key, value|
        value = value.map(&:to_s).join(',') if Array === value
        searches << "#{key}=#{value}"
      end
      uri += "?#{ searches.join('&') }"
    end
    URI(uri)
  end

  private def fetch http, uri
    # TODO: log
    request = Net::HTTP::Get::new uri
    request['User-Agent'] = config[:http][:user_agent] || 'INat::Get unknown instance'
    response = http.request request
    if Net::HTTPSuccess === response
      result = JSON.parse response.body
      @results += result['results']
      total = result['total_results']
      paged = result['per_page']
      if total > paged
        sleep WORK_SLEEP
        above = @results.map { |o| o.id }.max
        fetch http, make_uri(id_above: above)
      end
    else
      # TODO: log
      @status = STATUS_FAILED
    end
  end

  def execute
    @status = STATUS_WORKING
    begin
      https = config[:http][:api_root].start_with? 'https://'
      uri = make_uri
      Net::HTTP::start uri.host, uri.port, use_ssl: https do |http|
        fetch http, uri
      end
      @status = STATUS_COMPLETED if @status != STATUS_FAILED
    rescue Exception => e
      # TODO: log
      @status = STATUS_FAILED
    rescue
      # TODO: log
      @status = STATUS_FAILED
    end
  end

end
