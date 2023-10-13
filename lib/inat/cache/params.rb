# frozen_string_literal: true

require_relative '../../app/globals'
require_relative '../../data/types/location'
require_relative 'params/condition'

module Params

  include LogDSL

  def prepare_params params
    api_params = {}
    db_params = []
    r_params = []
    params.each do |key, value|
      key = key.to_sym
      case key
      when :acc, :accuracy, :positional_accuracy
        case value
        when true, false                                  # not null, null
          api_params[:acc] = value
          db_params << [ "o.positional_accuracy IS #{ value && 'NOT' || '' } NULL", [] ]
          r_params << lambda { |o| value == !o.positional_accuracy.nil? }
        when Range
          min = value.begin
          max = value.end
          if Integer === min
            api_params[:acc_above] = min - 1
            db_params << [ "o.positional_accuracy >= ?", [ min ] ]
          elsif min != nil
            raise TypeError, "Invalid min value for accuracy: #{ min.inspect }!"
          end
          if Integer === max
            api_params[:acc_below] = max + 1
            db_params << [ "o.positional_accuracy <= ?", [ max ] ]
          elsif max != nil
            raise TypeError, "Invalid max value for accuracy: #{ max.inspect }!"
          end
          r_params << lambda { |o| value === o.positional_accuracy }
        when Numeric
          # no api selector
          db_params << [ "o.positional_accuracy = ?", [ value ] ]
          r_params << lambda { |o| o.positional_accuracy == value }
        else
          # no api selector
          # no db selector
          r_params << lambda { |o| value === o.positional_accuracy }
        end
      when :acc_above
        case value
        when Numeric
          api_params[:acc_above] = value
          db_params << [ "o.positional_accuracy > ?", [ value ] ]
          r_params << lambda { |o| o.positional_accuracy > value }
        else
          raise TypeError, "Invalid 'acc_above' value: #{ value.inspect }!"
        end
      when :acc_below
        case value
        when Numeric
          api_params[:acc_below] = value
          db_params << [ "o.positional_accuracy < ?", [ value ] ]
          r_params << lambda { |o| o.positional_accuracy < value }
        else
          raise TypeError, "Invalid 'acc_below' value: #{ value.inspect }!"
        end
      when :acc_below_or_unknown
        case value
        when Numeric
          api_params[:acc_below_or_unknown] = value
          db_params << [ "o.positional_accuracy IS NULL OR o.positional_accuracy < ?", [ value ] ]
          r_params << lambda { |o| o.positional_accuracy.nil? || o.positional_accuracy < value }
        else
          raise TypeError, "Invalid 'acc_below_or_unknown' value: #{ value.inspect }!"
        end
      when :captive
        case value
        when true, false
          api_params[:captive] = value
          db_params << [ "o.captive = ?", [ value ] ]
          r_params << lambda { |o| o.captive == value }
        else
          raise TypeError, "Invalid 'captive' value: #{ value.inspect }!"
        end
      when :endemic
        case value
        when true, false
          api_params[:endemic] = value
          # no db selector
          # no ruby selector
          # (требуется более сложная структура для отслеживания)
          warning "Unimpmented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'endemic' value: #{ value.inspect }!"
        end
      when :geo, :location
        case value
        when true, false
          api_params[:geo] = value
          db_params << [ "o.location IS #{ value && 'NOT' || '' } NULL", [] ]
          r_params << lambda { |o| value == !(o.location.nil? || o.location.empty?) }
        when Location
          api_params[:lat] = value.latitude if value.latitude
          api_params[:lng] = value.longitude if value.longitude
          api_params[:radius] = value.radius / 1000 if value.radius
          # no db selector
          # (нужно вводить дополнительную струкутру)
          # no ruby selector
          # (нужны вычисления)
          # TODO: implement ruby selector
          warning "Unimpmented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid location value: #{ value.inspect }!"
        end
      when :id_please
        case value
        when true, false
          api_params[:id_please] = value
          # no db selector
          # no ruby selector
          warning "Unimpmented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'id_please' value: #{ value.inspect }!"
        end
      when :identified
        case value
        when true, false
          api_params[:identified] = value
          db_params << [ "o.community_taxon_id IS #{ value && 'NOT' || '' } NULL", [] ]
          r_params << lambda { |o| value == !o.community_taxon.nil? }
        else
          raise TypeError, "Invalid 'identified' value: #{ value.inspect }!"
        end
      when :introduced
        case value
        when true, false
          api_params[:introduced] = value
          # no db selector
          # no ruby selector
          # (требуется более сложная структура)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'introduced' value: #{ value.inspect }!"
        end
      when :mappable
        case value
        when true, false
          api_params[:mappable] = value
          db_params << [ "o.mappable = ?", [ value ] ]
          r_params << lambda { |o| o.mappable == value }
        else
          raise TypeError, "Invalid 'mappable' value: #{ value.inspect }!"
        end
      when :native
        case value
        when true, false
          api_params[:native] = value
          # no db selector
          # no ruby selector
          # (требуется более сложная структура)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'native' value: #{ value.inspect }!"
        end
      when :out_of_range
        case value
        when true, false
          api_params[:out_of_range] = value
          # no db selector
          # no ruby selector
          # (требуется более сложная структура)
          warning "Unimplementd on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'out_of_range' value: #{ value.inspect }!"
        end
      when :pcid
        case value
        when true, false
          api_params[:pcid] = value
          # no db selector
          # no ruby selector
          # TODO: сделать выборку, в том числе совместно с project_id
          warning "Unimplementd on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'pcid' value: #{ value.inspect }!"
        end
      when :photos
        case value
        when true, false
          api_params[:photos] = value
          # TODO: db selector
          r_params << lambda { |o| value == (!o.photos.nil? && !o.photos.empty?) }
        else
          raise TypeError, "Invalid 'photos' value: #{ value.inspect }!"
        end
      when :popular
        case value
        when true, false
          api_params[:popular] = value
          # TODO: db selector
          r_params << lambda { |o| value == (!o.faves.nil? && !o.faves.empty?) }
        else
          raise TypeError, "Invalid 'popular' value: #{ value.inspect }!"
        end
      when :sounds
        case value
        when true, false
          api_params[:sounds] = value
          # TODO: db selector
          r_params << lambda { |o| value == (!o.sounds.nil? && !o.sounds.empty?) }
        else
          raise TypeError, "Invalid 'sounds' value: #{ value.inspect }!"
        end
      when :taxon_is_active
        case value
        when true, false
          api_params[:taxon_is_active] = value
          # no db selector
          # no ruby selector
          warning "Unimplemented on cache: #{ key } => #{ value }!"
        else
          raise TypeError, "Invalid 'taxon_is_active' value: #{ value.inspect }!"
        end
      end
    end
    [ api_params, db_params, r_params ]
  end

  module_function :prepare_params

end
