# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

require_relative '../app/globals'

module API

  RECORDS_LIMIT = 200
  FREQUENCY_LIMIT = 1.0

  class << self

    include LogDSL

    def get path, part, limit, *ids
      return [] if ids.empty?
      if ids.size > limit
        rest = ids.dup
        head = rest.shift limit
        return get(path, *head) + get(path, *rest)
      end
      result = []
      @mutex ||= Mutex::new
      @mutex.synchronize do
        now = Time::new
        if @last_call && now - @last_call < FREQUENCY_LIMIT
          sleep FREQUENCY_LIMIT - (now - @last_call)
        end
        case part
        when :query
          url = G.config[:api][:root] + path.to_s + "?id=#{ ids.join(',') }"
          url += "&per_page=#{ limit }"
          locale = G.config[:api][:locale]
          url += "&locale=#{ locale }" if locale
          preferred_place_id = G.config[:api][:preferred_place_id]
          url += "&preferred_place_id=#{ preferred_place_id }" if preferred_place_id
        when :path
          url = G.config[:api][:root] + path.to_s + "/#{ ids.join(',') }"
        else
          raise ArgumentError, "Invalid 'part' argument: #{ part.inspect }!", caller
        end
        uri = URI(url)
        info "GET: URI = #{ uri.inspect }"
        https = uri.scheme == 'https'
        open_timeout = G.config[:api][:open_timeout]
        read_timeout = G.config[:api][:read_timeout]
        http_options = {
          use_ssl: https
        }
        http_options[:open_timeout] = open_timeout if open_timeout
        http_options[:read_timeout] = read_timeout if read_timeout
        answered = false
        answer_count = 10
        last_time = Time::new
        until answered
          begin
            Net::HTTP::start uri.host, uri.port, **http_options do |http|
              request = Net::HTTP::Get::new uri
              request['User-Agent'] = G.config[:api][:user_agent] || "INat::Get // Unknown Instance"
              response = http.request request
              if Net::HTTPSuccess === response
                data = JSON.parse(response.body)
                result = data['results']
                total = data['total_results']
                paged = data['per_page']
                time_diff = Time::new - last_time
                debug "GET OK: total = #{ total } paged = #{ paged } time = #{ time_diff } "
              else
                error "Bad response: #{ response.inspect }!"
              end
            end
            answered = true
          rescue OpenSSL::SSL::SSLError, Timeout::Error
            if answer_count > 0
              answer_count -= 1
              answered = false
              error "Error in HTTP request: #{ $!.inspect }, retry: #{ answer_count }."
              sleep 2.0
            else
              answered = true
              error "Error in HTTP request: #{ $!.inspect }!"
            end
          end
        end
        @last_call = Time::new
      end
      result
    end

    private def make_url path, **params
      url = G.config[:api][:root] + path.to_s
      query = []
      params.each do |key, value|
        query_param = "#{ key }="
        if Array === value
          query_param += value.map(&:to_query).join(',')
        else
          query_param += value.to_query
        end
        query << query_param
      end
      locale = G.config[:api][:locale]
      query << "locale=#{ locale }" if locale
      preferred_place_id = G.config[:api][:preferred_place_id]
      query << "preferred_place_id=#{ preferred_place_id }" if preferred_place_id
      if !query.empty?
        url += "?" + query.join('&')
      end
      url
    end

    def query path, first_only: false, **params, &block
      para = params.dup
      para.delete_if { |key, _| key.intern == :page }
      para[:per_page] = RECORDS_LIMIT
      para[:order_by] = :id
      para[:order]    = :asc
      result = []
      rest = nil
      total = 0
      @mutex ||= Mutex::new
      @mutex.synchronize do
        now = Time::new
        if @last_call && now - @last_call < FREQUENCY_LIMIT
          sleep FREQUENCY_LIMIT - (now - @last_call)
        end
        url = make_url path, **para
        uri = URI(url)
        info "QUERY: URI = #{ uri.inspect }"
        https = uri.scheme == 'https'
        open_timeout = G.config[:api][:open_timeout]
        read_timeout = G.config[:api][:read_timeout]
        http_options = {
          use_ssl: https
        }
        http_options[:open_timeout] = open_timeout if open_timeout
        http_options[:read_timeout] = read_timeout if read_timeout
        answered = false
        answer_count = 10
        last_time = Time::new
        until answered
          begin
            Net::HTTP::start uri.host, uri.port, **http_options do |http|
              request = Net::HTTP::Get::new uri
              request["User-Agent"] = G.config[:api][:user_agent] || "INat::Get // Unknown Instance"
              response = http.request request
              if Net::HTTPSuccess === response
                data = JSON.parse(response.body)
                result = data["results"]
                total = data["total_results"]
                paged = data["per_page"]
                time_diff = Time::new - last_time
                debug "QUERY OK: total = #{ total } paged = #{ paged } time = #{ time_diff } "
                if total > paged && !first_only
                  max = result.map { |o| o["id"] }.max
                  rest = para
                  rest[:id_above] = max
                end
              else
                raise RuntimeError, "Invalid response: #{response.inspect}"
              end
            end
            answered = true
          rescue OpenSSL::SSL::SSLError, Timeout::Error
            if answer_count > 0
              answer_count -= 1
              answered = false
              error "Error in HTTP request: #{ $!.inspect }, retry: #{ answer_count }."
              sleep 2.0
            else
              raise
            end
          end
        end
        @last_call = Time::new
      end
      # TODO: переделать рекурсию в итерации
      if block_given?
        rr = []
        result.each do |js_object|
          rr << yield(js_object, total)
        end
        rr += query(path, **rest, &block) if rest
        rr
      else
        result += query(path, **rest) if rest
        result
      end
    end

    def load_file filename
      data = JSON.parse File.read(filename)
      data['results']
    end

  end

end
