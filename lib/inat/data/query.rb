# frozen_string_literal: true

require 'uri'
require 'date'

require 'extra/period'

require_relative '../app/globals'
require_relative 'db'
require_relative 'entity/request'

class Query

  private def parse_accuracy value
    case value
    when true, false
      @api_params[:acc] = value
      @db_where << [ "o.positional_accuracy IS#{ value && ' NOT' || '' } NULL", [] ]
      @r_match << lambda { |o| o.positional_accuracy != nil }
    when Integer
      @api_params[:acc_above] = value - 1
      @api_params[:acc_below] = value + 1
      @db_where << [ "o.positional_accuracy = ?", [ value.to_i ] ]
      @r_match << lambda { |o| o.positional_accuracy == value }
    when Range
      min = value.begin
      max = value.end
      if min != nil
        @api_params[:acc_above] = min.to_i - 1
        @db_where << [ "o.positional_accuracy >= ?", [ min ] ]
      end
      if max != nil
        @api_params[:acc_below] = max.to_i + 1
        @db_where << [ "o.positional_accuracy <#{ value.exclude_end? && '' || '=' } ?", [ max ] ]
      end
      @r_match << lambda { |o| value === o.positional_accuracy }
    else
      raise TypeError, "Invalid 'accuracy' type: #{ value.inspect }!", caller[1..]
    end
  end

  def parse_acc_above value
    case value
    when Integer
      @api_params[:acc_above] = value
      @db_where << [ "o.positional_accuracy > ?", [ value ] ]
      @r_match << lambda { |o| o.positional_accuracy > value }
    else
      raise TypeError, "Invalid 'acc_above' type: #{ value.inspect }!", caller[1..]
    end
  end

  def parse_acc_below value
    case value
    when Integer
      @api_params[:acc_below] = value
      @db_where << [ "o.positional_accuracy < ?", [ value ] ]
      @r_match << lambda { |o| o.positional_accuracy < value }
    else
      raise TypeError, "Invalid 'acc_below' type: #{ value.inspect }!", caller[1..]
    end
  end

  def parse_acc_below_or_unknown value
    case value
    when Integer
      @api_params[:acc_below_or_unknown] = value
      @db_where << [ "o.positional_accuracy < ? OR o.positional_accuracy IS NULL", [ value ] ]
      @r_match << lambda { |o| o.positional_accuracy == nil || o.positional_accuracy < value }
    else
      raise TypeError, "Invalid 'acc_below_or_unknown' type: #{ value.inspect }!", caller[1..]
    end
  end

  def parse_captive value
    case value
    when true, false
      @api_params[:captive] = value
      @db_where << [ "o.captive = ?", [ value.to_db ] ]
      @r_match << lambda { |o| o.captive == value }
    else
      raise TypeError, "Invalid 'captive' type: #{ value.inspect }!", caller[1..]
    end
  end

  def initialize **params
    @api_params = {}
    @db_where = []
    @r_match = []

    params.each do |key, value|
      key = key.intern
      case key
      when :acc, :accuracy, :positional_accuracy
        parse_accuracy value
      when :acc_above
        parse_acc_above value
      when :acc_below
        parse_acc_below value
      when :acc_below_or_unknown
        parse_acc_below_or_unknown value
      when :captive
        parse_captive value
      else
        raise ArgumentError, "Invalid key: #{ key }", caller
      end
    end
  end

  private def parse_query query_string
    result = {}
    params = query_string.split '&'
    params.each do |param|
      para = param.split '='
      result[para[0].intern] = URI.decode_uri_component(para[1])
    end
    result
  end

  private def array_covers own, other
    own = own.map { |i| i.to_s }
    other = other.map { |i| i.to_s }
    other.all? { |i| own.include?(i) }
  end

  def in? query_string
    query_params = parse_query query_string
    query_params.each do |key, value|
      own_param = @api_params[key]
      case own_param
      when nil
        return false
      when Array
        if key.start_with?('not_') || key.start_with?('without')
          return false unless array_covers(value.split(','), own_param)
        else
          return false unless array_covers(own_param, value.split(','))
        end
      when Date
        value = Date::parse value
        if key.end_with?('1')
          return false unless own_param <= value
        elsif key.end_with?('2')
          return false unless own_param >= value
        end
      else
        return false unless own_param == value
      end
    end
    return true
    # TODO: обрабатывать вложенность таксонов, мест и проектов, а также координат.
  end

  def api_query
    @api_params.map { |k, v| "#{ k }=#{ URI.encode_uri_component(v.to_query) }" }.sort.join("&")
  end

  def db_where
    sql = []
    sql_args = []
    @db_where.each do |item|
      sql << item[0]
      sql_args << item[1]
    end
    [ sql.map { |s| "(#{s})" }.join(' AND '), sql_args.flatten ]
  end

  def match? observation
    @r_match.all? { |m| m === observation }
  end

  def === observation
    match? observation
  end

  def observations
    mode = G.config[:data][:update]
    mode = UpdateMode[mode] if Symbol === mode || Integer === mode
    mode = UpdateMode::parse(mode) if String === mode
    if mode != UpdateMode::OFFLINE
      actuals = []
      if mode != UpdateMode::RELOAD
        # 1. Проверяем наличие актуального реквеста
        actual_time = 0
        if mode != UpdateMode::MINIMAL
          actual_time = Time::new - Period::parse(G.config[:data][:update_period])
        end
        actuals = DB.execute("SELECT * FROM requests WHERE time >= ?", actual_time.to_db).map { |rec| Request::parse(rec) }.select { |rq| self.in?(rq.query) }
      end
      if actuals.empty? || mode == UpdateMode::FORCE
        # 2. Ищем чего бы обновить
        request = DB.execute("SELECT * FROM requests WHERE query = ?", api_query).map { |r| Request::parse(r) }.first
        updated_since = nil
        if request == nil
          query_string = api_query
          project_id = @api_params[:project_id]
          project_id = nil unless Integer === project_id
          request = Request::create query_string, project_id
        else
          updated_since = request.time if mode != UpdateMode::RELOAD
        end
        params = @api_params
        params[:updated_since] = updated_since if updated_since
        request.time = Time::new
        request.save
        API::query(:observations, **params).each do |json|
          Observation::parse json
        end
      end
    end
    sql, sql_args = db_where
    DB.execute("SELECT * FROM observations WHERE #{ sql };", *sql_args).filter { |o| self.match?(o) }
  end

end
