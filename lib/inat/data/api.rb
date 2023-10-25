# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

require_relative '../app/globals'

module API

  RECORDS_LIMIT = 200
  FREQUENCY_LIMIT = 1.0

  class << self

    def get path, *ids
      return [] if ids.empty?
      if ids.size > RECORDS_LIMIT
        rest = ids.dup
        head = rest.shift RECORDS_LIMIT
        return get(path, *head) + get(path, *rest)
      end
      if path == :users
        rest = ids.dup
        head = rest.shift
        return get(path, head) + get(path, *rest)
      end
      result = []
      @mutex ||= Mutex::new
      @mutex.synchronize do
        now = Time::new
        if @last_call && now - @last_call < FREQUENCY_LIMIT
          sleep FREQUENCY_LIMIT - (now - @last_call)
        end
        case path
        when :taxa, :observations
          url = G.config[:api][:root] + path.to_s + "?id=#{ ids.join(',') }"
          locale = G.config[:api][:locale]
          url += "&locale=#{ locale }" if locale
          preferred_place_id = G.config[:api][:preferred_place_id]
          url += "&preferred_place_id=#{ preferred_place_id }" if preferred_place_id
        else
          url = G.config[:api][:root] + path.to_s + "/#{ ids.join(',') }"
        end
        uri = URI(url)
        https = uri.scheme == 'https'
        Net::HTTP::start uri.host, uri.port, use_ssl: https do |http|
          request = Net::HTTP::Get::new uri
          request['User-Agent'] = G.config[:api][:user_agent] || "INat::Get // Unknown Instance"
          response = http.request request
          if Net::HTTPSuccess === response
            result = JSON.parse(response.body)['results']
          else
            raise RuntimeError, "Invalid response: #{ response.inspect }"
          end
        end
        @last_call = Time::new
      end
      result
    end

    private def make_url path, **params
      url = G.config[:api][:root] + path
      query = []
      params.each do |key, value|
        query_param = "#{ key }="
        if Array === value
          query_param += URI.encode_uri_component value.map(&:to_s).join(',')
        else
          query_param += URI.encode_uri_component value.to_s
        end
        query << query_param
      end
      if !query.empty?
        url += "?" + query.join('&')
      end
      url
    end

    def query path, **params
      para = params.dup
      para.delete_if { |key, _| key.intern == :page }
      para[:per_page] = RECORDS_LIMIT
      para[:order_by] = :id
      para[:order]    = :asc
      result = []
      rest = nil
      @mutex ||= Mutex::new
      @mudex.synchronize do
        now = Time::new
        if @last_call && now - @last_call < FREQUENCY_LIMIT
          sleep FREQUENCY_LIMIT - (now - @last_call)
        end
        url = make_url path, **params
        uri = URI(url)
        https = uri.scheme == 'https'
        Net::HTTP::start uri.host, uri.port, use_ssl: https do |http|
          request = Net::HTTP::Get::new uri
          request['User-Agent'] = G.config[:api][:user_agent] || "INat::Get // Unknown Instance"
          response = http.request request
          if Net::HTTPSuccess === response
            data = JSON.parse(response.body)
            result = data['results']
            total = data['total_results']
            paged = data['per_page']
            if total > paged
              max = result.map { |o| o.id }.max
              rest = para
              rest[:id_above] = max
            end
          else
            raise RuntimeError, "Invalid response: #{ response.inspect }"
          end
        end
      end
      result += query path, **rest if rest
      result
    end

    def load_file filename
      data = JSON.parse File.read(filename)
      data['results']
    end

  end

end
