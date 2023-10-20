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
          # NEED: db and ruby selector
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
          # NEED: db selector
          r_params << lambda { |o| value == (!o.photos.nil? && !o.photos.empty?) }
        else
          raise TypeError, "Invalid 'photos' value: #{ value.inspect }!"
        end
      when :popular
        case value
        when true, false
          api_params[:popular] = value
          # NEED: db selector
          r_params << lambda { |o| value == (!o.faves.nil? && !o.faves.empty?) }
        else
          raise TypeError, "Invalid 'popular' value: #{ value.inspect }!"
        end
      when :sounds
        case value
        when true, false
          api_params[:sounds] = value
          # NEED: db selector
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
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }"
        else
          raise TypeError, "Invalid 'taxon_is_active' value: #{ value.inspect }!"
        end
      when :threatened
        case value
        when true, false
          api_params[:threatened] = value
          # no db selector
          # no ruby selector
          # NEED: ruby selector at least
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'threatened' value: #{ value.inspect }!"
        end
      when :verifiable
        case value
        when true, false
          api_params[:verifiable] = value
          db_params << [ "o.quality_grade #{ value && '' || 'NOT' } IN ('needs_id', 'research')", [] ]
          r_params << lambda { |o| [:needs_id, :research].include?(o.quality_grade) }
        else
          raise TypeError, "Invalid 'verifiable' value: #{ value.inspect }!"
        end
      when :licensed
        case value
        when true, false
          api_params[:licensed] = value
          db_params << [ "o.license_code IS #{ value && 'NOT' || '' } NULL", [] ]
          r_params << lambda { |o| value == !o.license_code.nil? }
        else
          raise TypeError, "Invalid 'licensed' value: #{ value.inspect }!"
        end
      when :photo_licensed
        case value
        when true, false
          api_params[:photo_licensed] = value
          # NEED: db selector
          r_params << lambda { |o| value == !(o.photos.nil? || o.photos.all? { |p| p.license_code.nil? }) }
        else
          raise TypeError, "Invalid 'photo_licensed' value: #{ value.inspect }!"
        end
      when :id
        case value
        when Integer
          api_params[:id] = value
          db_params << [ "o.id = ?", [ value ] ]
          r_params << lambda { |o| o.id == value }
        when Array
          api_params[:id] = value
          db_params << [ "o.id IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.include?(o.id) }
        when Range
          min = value.begin
          max = value.end
          if min != nil
            api_params[:id_above] = min - 1
            db_params << [ "o.id >= ?", [ min ] ]
            r_params << lambda { |o| o.id >= min }
          end
          if max != nil
            api_params[:id_below] = max + 1
            db_params << [ "o.id <= >", [ max ] ]
            r_params << lambda { |o| o.id <= max }
          end
        else
          raise TypeError, "Invalid 'id' value: #{ value.inspect }!"
        end
      when :not_id
        case value
        when Integer
          api_params[:not_id] = value
          db_params << [ "o.id != ?", [ value ] ]
          r_params << lambda { |o| o.id != value }
        when Array
          api_params[:not_id] = value
          db_params << [ "o.id NOT IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| !value.include?(o.id) }
        else
          raise TypeError, "Invalid 'not_id' value: #{ value.inspect }!"
        end
      when :license
        case value
        when String, Symbol
          api_params[:license] = value
          db_params << [ "o.license_code = ?", [ value ] ]
          r_params << lambda { |o| o.license_code == value.intern }
        when Array
          api_params[:license] = value
          db_params << [ "o.license_code IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.map(&:intern).include?(o.license_code) }
        else
          raise TypeError, "Invalid 'license' value: #{ value.inspect }!"
        end
      when :ofv_datatype
        case value
        when String, Symbol
          api_params[:ofv_datatype] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        when Array
          api_params[:ofv_datatype] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'ovf_datatype' value: #{ value.inspect }!"
        end
      when :photo_license
        case value
        when String, Symbol
          api_params[:photo_license] = value
          # NEED: db selector
          r_params << lambda { |o| o.photos.any? { |p| p.license_code == value.intern } }
        when Array
          api_params[:photo_license] = value
          # NEED: db selector
          r_params << lambda { |o| o.photos.any? { |p| value.map(&:intern).include?(p.license_code) } }
        else
          raise TypeError, "Invalid 'photo_license' value: #{ value.inspect }!"
        end
      when :place_id
        case value
        when Integer
          api_params[:place_id] = value
          # NEED: implement db selector
          r_params << lambda { |o| o.places.map(&:id).include?(value) }
        when Array
          api_params[:place_id] = value
          # NEED: implement db selector
          r_params << lambda { |o| value.any? { |p| o.places.map(&:id).include?(p) } }
        else
          raise TypeError, "Invalid 'place_id' value: #{ value.inspect }!"
        end
      when :place, :places
        case value
        when Place
          api_params[:place_id] = value.id
          # NEED: implement db selector
          r_params << lambda { |o| o.places.include?(value) }
        when Array
          api_params[:place_id] = value.map(&:id)
          # NEED: implement db selector
          r_params << lambda { |o| value.any? { |p| o.places.include?(p) } }
        else
          raise TypeError, "Invalid 'place' value: #{ value.inspect }!"
        end
      when :project_id
        case value
        when Integer
          api_params[:project_id] = value
          # NEED: implement db selector
          r_params << lambda { |o| o.projects.map(&:id).include?(value) }
        when String, Symbol
          api_params[:project_id] = value
          # NEED: implement db selector
          r_params << lambda { |o| o.projects.map(&:slug).include?(value) }
        when Array
          api_params[:project_id] = value
          # NEED: implement db selector
          r_params << lambda { |o| value.any? { |p| o.projects.map { |i| [i.id, i.slug] }.flatten.include?(p) } }
        else
          raise TypeError, "Invalid 'project_id' value: #{ value.inspect }!"
        end
      when :project, :projects
        case value
        when Project
          api_params[:project_id] = value.id
          # NEED: implement db selector
          r_params << lambda { |o| o.projects.include?(value) }
        when Array
          api_params[:project_id] = value.map(&:id)
          # NEED: implement db selector
          r_params << lambda { |o| value.any? { |p| o.projects.include?(p) } }
        else
          raise TypeError, "Invalid 'project' value: #{ value.inspect }!"
        end
      when :rank
        case value
        when String, Symbol
          api_params[:rank] = value
          # NEED: implement db selector
          r_params << lambda { |o| o.taxon.rank == value.intern }
        when Array
          api_params[:rank] = value
          # NEED: implement db selector
          r_params << lambda { |o| value.any? { |r| o.taxon.rank == r.intern } }
        when Range
          # NEED: implement all selectors
          warning "Unimplemented range for #{key }!"
        else
          raise TypeError, "Invalid 'rank' value: #{ value.inspect }!"
        end
      when :hrank
        case value
        when String, Symbol
          api_params[:hrank] = value
          # NEED: implement db selector
          # NEED: implement ruby selector
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'hrank' value: #{ value.inspect }!"
        end
      when :lrank
        case value
        when String, Symbol
          api_params[:lrank] = value
          # NEED: implement db selector
          # NEED: implement ruby selector
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'lrank' value: #{ value.inspect }!"
        end
      when :site_id
        api_params[:site_id] = value
        # no db selector
        # no ruby selector
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :sound_license
        case value
        when String, Symbol
          api_params[:sound_license] = value
          # NEED: db selector
          r_params << lambda { |o| o.sounds.any? { |s| s.license_code == value.intern } }
        when Array
          api_params[:sound_license] = value
          # NEED: db selector
          r_params << lambda { |o| o.sounds.any? { |s| value.map(&:intern).include?(p.license_code) } }
        else
          raise TypeError, "Invalid 'sound_license' value: #{ value.intern }!"
        end
      when :taxon_id
        case value
        when Integer
          api_params[:taxon_id] = value
          # NEED: db selector
          r_params << lambda { |o| o.ident_taxon_ids.include?(value) }
        when Array
          api_params[:taxon_id] = value
          # NEED: db selector
          r_params << lambda { |o| value.any? { |t| o.ident_taxon_ids.include?(t) } }
        else
          raise TypeError, "Invalid 'taxon_id' value: #{ value.inspect }!"
        end
      when :without_taxon_id
        case value
        when Integer
          api_params[:without_taxon_id] = value
          # NEED: db selector
          r_params << lambda { |o| !o.ident_taxon_ids.include?(value) }
        when Array
          api_params[:without_taxon_id] = value
          # NEED: db selector
          r_params << lambda { |o| !value.any? { |t| o.ident_taxon_ids.include?(t) } }
        else
          raise TypeError, "Invalid 'without_taxon_id' value: #{ value.inspect }!"
        end
      when :taxon, :taxa
        case value
        when Taxon
          api_params[:taxon_id] = value.id
          # NEED: db selector
          r_params << lambda { |o| o.ident_taxa.include?(value) }
        when Array
          api_params[:taxon_id] = value.map(&:id)
          # NEED: db selector
          r_params << lambda { |o| value.any? { |t| o.ident_taxa.include?(t) } }
        else
          raise TypeError, "Invalid 'taxon' value: #{ value.inspect }!"
        end
      when :without_taxon, :without_taxa
        case value
        when Taxon
          api_params[:without_taxon_id] = value.id
          # NEED: db selector
          r_params << lambda { |o| !o.ident_taxa.include?(value) }
        when Array
          api_params[:without_taxon_id] = value.map(&:id)
          # NEED: db selector
          r_params << lambda { |o| !value.any? { |t| o.ident_taxa.include?(t) } }
        else
          raise TypeError, "Invalid 'without_taxon' value: #{ value.inspect }!"
        end
      when :taxon_name
        api_params[:taxon_name] = value
        # TODO: db and ruby selector
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :user_id
        case value
        when Integer
          api_params[:user_id] = value
          db_params << [ "o.user_id = ?", [value] ]
          r_params << lambda { |o| o.user_id == value }
        when Array
          api_params[:user_id] = value
          db_params << [ "o.user_id IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.include?(o.user_id) }
        else
          raise TypeError, "Invalid 'user_id' value: #{ value.inspect }!"
        end
      when :user, :users
        case value
        when User
          api_params[:user_id] = value.id
          db_params << [ "o.user_id = ?", [value.id] ]
          r_params << lambda { |o| o.user == value }
        when Array
          api_params[:user_id] = value.map(&:id)
          db_params << [ "o.user_id IN (#{ (['?'] * value.size).join(',') })", value.map(&:id) ]
          r_params << lambda { |o| value.include?(o.user) }
        else
          raise TypeError, "Invalid 'user' value: #{ value.inspect }!"
        end
      when :user_login
        case value
        when String, Symbol
          api_params[:user_login] = value
          # NEED: db selector
          r_params << lambda { |o| o.user.login == value.to_s }
        when Array
          api_params[:user_login] = value
          # NEED: db selector
          r_params << lambda { |o| value.map(&:to_s).include?(o.user.login) }
        else
          raise TypeError, "Invalid 'user_login' value: #{ value.inspect }!"
        end
      when :ident_user_id
        case value
        when Integer
          api_params[:ident_user_id] = value
          # NEED: db selector
          r_params << lambda { |o| o.identifications.any? { |i| i.user.id == value } }
        else
          raise TypeError, "Invalid 'ident_user_id' value: #{ value.inspect }!"
        end
      when :day
        case value
        when Integer, String
          api_params[:day] = value
          # NEED: db selector
          r_params << lambda { |o| o.observed_on.day == value.to_i }
        when Array
          api_params[:day] = value
          # NEED: db_selector
          r_params << lambda { |o| value.map(&:to_i).include?(o.observed_on.day) }
        else
          raise TypeError, "Invalid 'day' value: #{ value.inspect }!"
        end
      when :month
        case value
        when Integer, String
          api_params[:month] = value
          # NEED: db selector
          r_params << lambda { |o| o.observed_on.month == value.to_i }
        when Array
          api_params[:month] = value
          # NEED: db selector
          r_params << lambda { |o| value.map(&:to_i).include?(o.observed_on.month) }
        else
          raise TypeError, "Invalid 'month' value: #{ value.inspect }!"
        end
      when :year
        case value
        when Integer, String
          api_params[:year] = value
          # NEED: db selector
          r_params << lambda { |o| o.observed_on.year == value.to_i }
        when Array
          api_params[:year] = value
          # NEED: db selector
          r_params << lambda { |o| value.map(&:to_i).include?(o.observed_on.year) }
        else
          raise TypeError, "Invalid 'year' value: #{ value.inspect }!"
        end
      when :term_id
        api_params[:term_id] = value
        # TODO: разобраться с термами
      when :term_value_id
        api_params[:term_value_id] = value
        # TODO: разобраться с термами
      when :without_term_id
        api_params[:without_term_id] = value
        # TODO: разобраться с термами
      when :without_term_value_id
        api_params[:without_term_value_id] = value
        # TODO: разобраться с термами
      when :d1
        case value
        when String
          api_params[:d1] = value
          date = Date::parse(value)
          time = date.to_time.to_i
          db_params << [ "o.observed_on >= ?", [ time ] ]
          r_params << lambda { |o| o.observed_on >= date }
        when Time
          date = value.to_date
          time = date.to_time.to_i
          api_params[:d1] = date.xmlschema
          db_params << [ "o.observed_on >= ?", [ time ] ]
          r_params << lambda { |o| o.observed_on >= date }
        when Date
          date = value
          time = date.to_time.to_i
          api_params[:d1] = date.xmlschema
          db_params << [ "o.observed_on >= ?", [ time ] ]
          r_params << lambda { |o| o.observed_on >= date }
        else
          raise TypeError, "Invalid 'd1' value: #{ value.inspect }!"
        end
      when :d2
        case value
        when String
          api_params[:d2] = value
          date = Date::parse(value)
          time = date.to_time.to_i
          db_params << [ "o.observed_on < ?", [ time + 24 * 60 * 60 ] ]
          r_params << lambda { |o| o.observed_on <= date }
        when Time
          date = value.to_date
          time = date.to_time.to_i
          api_params[:d2] = date.xmlschema
          db_params << [ "o.observed_on < ?", [ time + 24 * 60 * 60 ] ]
          r_params << lambda { |o| o.observed_on <= date }
        when Date
          date = value
          time = date.to_time.to_i
          api_params[:d2] = date.xmlschema
          db_params << [ "o.observed_on < ?", [ time + 24 * 60 * 60 ] ]
          r_params << lambda { |o| o.observed_on <= date }
        else
          raise TypeError, "Invalid 'd2' value: #{ value.inspect }!"
        end
      when :created_d1
        case value
        when String
          api_params[:created_d1] = value
          time = Time::parse(value)
          db_params << [ "o.created_at >= ?", [ time.to_i ] ]
          r_params << lambda { |o| o.created_at >= time }
        when Time
          api_params[:created_d1] = value.xmlschema
          db_params << [ "o.created_at >= ?", [ value.to_i ] ]
          r_params << lambda { |o| o.created_at >= value }
        when Date
          time = value.to_time
          api_params[:created_d1] = time.xmlschema
          db_params << [ "o.created_at >= ?", [ time.to_i ] ]
          r_params << lambda { |o| o.created_at >= time }
        else
          raise TypeError, "Invalid 'created_d1' value: #{ value.inspect }!"
        end
      when :created_d2
        case value
        when String
          api_params[:created_d2] = value
          time = Time::parse(value)
          db_params << [ "o.created_at < ?", [ time.to_date.to_time.to_i + 24 * 60 * 60 ] ]
          r_params << lambda { |o| o.created_at <= time }
        when Time
          api_params[:created_d2] = value.xmlschema
          db_params << [ "o.created_at <= ?", [ value.to_i ] ]
          r_params << lambda { |o| o.created_at <= value }
        when Date
          time = value.to_time
          api_params[:created_d2] = time.xmlschema
          db_params << [ "o.created_at < ?", [ time.to_i + 24 * 60 * 60 ] ]
          r_params << lambda { |o| o.created_at <= time }
        else
          raise TypeError, "Invalid 'created_d2' value: #{ value.inspect }!"
        end
      when :created_on
        case value
        when String
          date = Date::parse value
          time = date.to_time.to_i
          next_time = time + 24 * 60 * 60
          api_params[:created_on] = value
          db_params << [ "o.created_at >= ? AND o.created_at < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.created_at.to_date == date }
        when Time
          date = value.to_date
          time = date.to_time.to_i
          next_time = time + 24 * 60 * 60
          api_params[:created_on] = date.xmlschema
          db_params << [ "o.created_at >= ? AND o.created_at < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.created_at.to_date == date }
        when Date
          time = value.to_time.to_i
          next_time = time + 24 + 60 + 60
          api_params[:created_on] = value.xmlschema
          db_params << [ "o.created_at >= ? AND o.created_at < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.created_at.to_date == value }
        when Range
          min = value.begin
          max = value.end
          if min != nil
            api_params[:created_d1] = min.xmlschema
            db_params << [ "o.created_at >= ?", [ min.to_date.to_time.to_i ] ]
            r_params << lambda { |o| o.created_at.to_date >= min.to_date }
          end
          if max != nil
            api_params[:created_d2] = max.xmlschema
            db_params << [ "o.created_at < ?", [ max.to_date.to_time.to_i + 24 * 60 * 60 ] ]
            r_params << lambda { |o| o.created_at.to_date <= max.to_date }
          end
        else
          raise TypeError, "Invalid 'created_on' value: #{ value.inspect }!"
        end
      when :observed_on
        case value
        when String
          date = Date::parse value
          time = Date.to_time.to_i
          next_time = time + 24 * 60 * 60
          api_params[:created_on] = value
          db_params << [ "o.observed_on >= ? AND o.observed_on < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.observed_on == date }
        when Time
          date = value.to_date
          time = date.to_time.to_i
          next_time = time + 24 * 60 * 60
          api_params[:created_on] = date.xmlschema
          db_params << [ "o.observed_on >= ? AND o.observed_on < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.observed_on == date }
        when Date
          date = value
          time = date.to_time.to_i
          next_time = time + 24 * 60 * 60
          api_params[:created_on] = date.xmlschema
          db_params << [ "o.observed_on >= ? AND o.observed_on < ?", [ time, next_time ] ]
          r_params << lambda { |o| o.observed_on == date }
        when Range
          min = value.begin
          max = value.end
          if min != nil
            api_params[:d1] = min.xmlschema
            db_params << [ "o.observed_on >= ?", [ min.to_date.to_time.to_i ] ]
            r_params << lambda { |o| o.observed_on >= min.to_date }
          end
          if max != nil
            api_params[:d2] = max.xmlschema
            db_params << [ "o.observed_on < ?", [ max.to_date.to_time.to_i + 24 * 60 * 60 ] ]
            r_params << lambda { |o| o.observed_on <= max.to_date }
          end
        else
          raise TypeError, "Invalid 'observed_on' value: #{ value.inspect }!"
        end
      when :unobserved_by_user_id
        case value
        when Integer
          api_params[:unobserved_by_user_id] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'unobserved_by_user_id' value: #{ value.inspect }!"
        end
      when :apply_project_rules_for
        case value
        when Integer, String, Symbol
          api_params[:apply_project_rules_for] = value
          # TODO: разобраться, можно ли вообще прокэшировать
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'apply_project_rules_for' value: #{ value.inspect }!"
        end
      when :not_matching_project_rules_for
        case value
        when Integer, String, Symbol
          api_params[:not_matching_project_rules_for] = value
          # TODO: разобраться, можно ли вообще прокэшировать
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'apply_project_rules_for' value: #{ value.inspect }!"
        end
      when :cs
        case value
        when String, Symbol
          api_params[:cs] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'cs' value: #{ value.inspect }!"
        end
      when :csa
        case value
        when String, Symbol
          api_params[:csa] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'csa' value: #{ value.inspect }!"
        end
      when :sci
        case value
        when String, Symbol, Array
          api_params[:csi] = value
          # TODO: db and ruby selector
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'csi' value: #{ value.inspect }!"
        end
      when :geoprivacy
        case value
        when String, Symbol
          api_params[:geoprivacy] = value.intern
          db_params << [ "o.geoprivacy = ?", [ value ] ]
          r_params << lambda { |o| o.geoprivacy == value.intern }
        when Array
          api_params[:geoprivacy] = value.map(&:intern)
          db_params << [ "o.geoprivacy IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.any? { |g| o.geoprivacy == g.intern } }
        else
          raise TypeError, "Invalid 'geoprivacy' value: #{ value.inspect }!"
        end
      when :taxon_geoprivacy
        case value
        when String, Symbol
          api_params[:taxon_geoprivacy] = value.intern
          db_params << [ "o.taxon_geoprivacy = ?", [ value ] ]
          r_params << lambda { |o| o.taxon_geoprivacy == value.intern }
        when Array
          api_params[:taxon_geoprivacy] = value.map(&:intern)
          db_params << [ "o.taxon_geoprivacy IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.any? { |g| o.taxon_geoprivacy == g.intern } }
        else
          raise TypeError, "Invalid 'taxon_geoprivacy' value: #{ value.inspect }!"
        end
      when :iconic_taxa
        case value
        when String, Symbol
          api_params[:iconic_taxa] = value
          # NEED: db selector
          r_params << lambda { |o| o.taxon.iconic_taxon_name == value.intern }
          # TODO: возможно, следует добавить сравнение и с community_taxon
        when Array
          api_params[:iconic_taxa] = value
          # NEED: db selector
          r_params << lambda { |o| value.any? { |t| o.taxon.iconic_taxon_name == t.intern } }
        else
          raise TypeError, "Invalid 'iconic_taxa' value: #{ value.inspect }!"
        end
      when :id_above
        case value
        when Integer
          api_params[:id_above] = value
          db_params << [ "o.id > ?", [ value ] ]
          r_params << lambda { |o| o.id > value }
        else
          raise TypeError, "Invalid 'id_above' value: #{ value.inspect }!"
        end
      when :id_below
        case value
        when Integer
          api_params[:id_below] = value
          db_params << [ "o.id < ?", [ value ] ]
          r_params << lambda { |o| o.id < value }
        else
          raise TypeError, "Invalid 'id_below' value: #{ value.inspect }!"
        end
      when :identifications
        case value
        when String, Symbol
          api_params[:identifications] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'identifications' value: #{ value.inspect }!"
        end
      when :lat
        case value
        when Numeric
          api_params[:lat] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'lat' value: #{ value.inspect }!"
        end
      when :lng
        case value
        when Numeric
          api_params[:lng] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'lng' value: #{ value.inspect }!"
        end
      when :radius
        case value
        when Numeric
          api_params[:radius] = value
          # TODO: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid 'radius' value: #{ value.inspect }!"
        end
      when :nelat
        case value
        when Numeric
          api_params[:nelat] = value
          # NEED: db and ruby selectors
          # (тут надо внести запись координат в основную таблицу в явном виде)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :nelng
        case value
        when Numeric
          api_params[:nelng] = value
          # NEED: db and ruby selectors
          # (тут надо внести запись координат в основную таблицу в явном виде)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :swlat
        case value
        when Numeric
          api_params[:swlat] = value
          # NEED: db and ruby selectors
          # (тут надо внести запись координат в основную таблицу в явном виде)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :swlng
        case value
        when Numeric
          api_params[:swlng] = value
          # NEED: db and ruby selectors
          #      (тут надо внести запись координат в основную таблицу в явном виде)
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :list_id
        case value
        when Integer
          api_params[:list_id] = value
          # TODO: подумать, что можно сделать. Хотя вряд ли.
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :not_in_project
        case value
        when Integer, String, Symbol
          api_params[:not_in_project] = value
          # NEED: db and ruby selectors
          warning "Unimplemented on cache: #{ key } => #{ value }."
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :q
        api_params[:q] = value
        # TODO: подумать о кэшировании
        #       может быть, использовать запрос only ID
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :search_on
        api_params[:search_on] = value
        # TODO: подумать о кэшировании
        #       может быть, использовать запрос only ID
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :quality_grade
        case value
        when String, Symbol
          api_params[:quality_grade] = value
          db_params << [ "o.quality_grade = ?", [ value ] ]
          r_params << lambda { |o| o.quality_grade == value.intern }
        when Array
          api_params[:quality_grade] = value
          db_params << [ "o.quality_grade IN (#{ (['?'] * value.size).join(',') })", value ]
          r_params << lambda { |o| value.any? { |g| o.quality_grade == g.intern } }
        else
          raise TypeError, "Invalid '#{ key }' value: #{ value.inspect }!"
        end
      when :updated_since
        api_params[:updated_since] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :viewer_id
        api_params[:viewer_id] = value
        # NEED: db and ruby selectors
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :reviewed
        api_params[:reviewed] = value
        # NEED: db and ruby selectors
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :locale
        api_params[:locale] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :preferred_place_id
        api_params[:preferred_place_id] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :ttl
        api_params[:ttl] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :page
        api_params[:page] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :per_page
        api_params[:per_page] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :order
        api_params[:order] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :order_by
        api_params[:order_by] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      when :only_id
        api_params[:only_id] = value
        # TODO: может, вообще не использовать?
        warning "Unimplemented on cache: #{ key } => #{ value }."
      end
    end
    [ api_params, db_params, r_params ]
  end

  module_function :prepare_params

end
