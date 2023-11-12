# frozen_string_literal: true

require 'uri'
require 'date'

require 'extra/period'

require_relative '../app/globals'
require_relative '../app/status'
require_relative 'db'
require_relative 'entity/request'
require_relative 'enums/qualitygrade'
require_relative 'types/std'
require_relative 'types/location'
require_relative 'types/extras'

class Query

  include LogDSL

  private def parse_accuracy value
    case value
    when true, false
      @api_params[:acc] = value
      @db_where << [ "o.positional_accuracy IS#{ value && ' NOT' || '' } NULL", [] ]
    when Integer
      @api_params[:acc_above] = value - 1
      @api_params[:acc_below] = value + 1
      @db_where << [ "o.positional_accuracy = ?", [ value.to_i ] ]
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
    else
      raise TypeError, "Invalid 'accuracy' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_acc_above value
    case value
    when Integer
      @api_params[:acc_above] = value
      @db_where << [ "o.positional_accuracy > ?", [ value ] ]
    else
      raise TypeError, "Invalid 'acc_above' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_acc_below value
    case value
    when Integer
      @api_params[:acc_below] = value
      @db_where << [ "o.positional_accuracy < ?", [ value ] ]
    else
      raise TypeError, "Invalid 'acc_below' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_acc_below_or_unknown value
    case value
    when Integer
      @api_params[:acc_below_or_unknown] = value
      @db_where << [ "o.positional_accuracy < ? OR o.positional_accuracy IS NULL", [ value ] ]
    else
      raise TypeError, "Invalid 'acc_below_or_unknown' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_captive value
    case value
    when true, false
      @api_params[:captive] = value
      @db_where << [ "o.captive = ?", [ value.to_db ] ]
    else
      raise TypeError, "Invalid 'captive' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_endemic value
    case value
    when true, false
      @api_params[:endemic] = value
      @db_where << [ "o.endemic = ?", [ value.to_db ] ]
    else
      raise TypeError, "Invalid 'endemic' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_introduced value
    case value
    when true, false
      @api_params[:introduced] = value
      @db_where << [ "o.introduced = ?", [ value.to_db ] ]
    else
      raise TypeError, "Invalid 'introduced' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_native value
    case value
    when true, false
      @api_params[:native] = value
      @db_where << [ "o.native = ?", [ value.to_db ] ]
    else
      raise TypeError, "Invalid 'native' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_mappable value
    case value
    when true, false
      @api_params[:mappable] = value
      @db_where << [ "o.mappable = ?", [ value.to_db ] ]
    else
      raise TypeError, "Invalid 'mappable' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_location value
    case value
    when true, false
      @api_params[:geo] = value
      @db_where << [ "o.location_latitude IS#{ value && ' NOT' || '' } NULL", [] ]
    when Radius
      @api_params[:lat] = value.latitude
      @api_params[:lng] = value.longitude
      @api_params[:radius] = value.radius
      @db_where << [ "o.location_latitude IS NOT NULL AND o.location_longitude IS NOT NULL AND (6371 * acos(sin(o.location_latitude*pi()/180)*sin(?*pi()/180) + cos(o.location_latitude*pi()/180)*cos(?*pi()/180))*cos((o.location_longitude - ?)*pi()/180) <= ?)", [ value.latitude, value.latitude, value.longitude, value.radius ] ]
      # @r_match << lambda { |o| o.location != nil && o.location.latitude != nil && o.location.longitude != nil &&
      #                          6371 * Math.acos(Math.sin(o.location.latitude*Math::PI/180)*Math.sin(value.latitude*Math::PI/180) +
      #                                           Math.cos(o.location.latitude*Math::PI/180)*Math.cos(value.latitude*Math::PI/180)*Math.cos((o.location.longitude - value.longitude)*Math::PI/180)) <= value.radius }
    when Sector
      @api_params[:nelat] = value.north
      @api_params[:nelng] = value.east
      @api_params[:swlat] = value.south
      @api_params[:swlng] = value.west
      @db_where << [ "o.location_latitude IS NOT NULL AND o.location_longitude IS NOT NULL AND o.location_latitude >= ? AND o.location_latitude <= ? AND o.location_longitude >= ? AND o.location_longitude <= ?",
                     [ value.south, value.north, value.west, value.east ] ]
      # @r_match << lambda { |o| o.location != nil && o.location.latitude != nil && o.location.longitude != nil &&
      #                          o.location.latitude >= value.south && o.location.latitude <= value.north &&
      #                          o.location.longitude >= value.west && o.location.longitude <= value.east }
    else
      raise TypeError, "Invalid 'location' type: #{ value.inspect }!"
    end
  end

  private def parse_photos value
    case value
    when true, false
      @api_params[:photos] = value
      @db_where << [ "#{ value && '' || 'NOT ' }EXISTS (SELECT * FROM observation_photos WHERE observation_id = o.id)", [] ]
      # @r_match << lambda { |o| (o.observation_photos == nil || o.observation_photos.empty?) != value }
    else
      raise TypeError, "Invalid 'photos' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_sounds value
    case value
    when true, false
      @api_params[:sounds] = value
      @db_where << [ "#{ value && '' || 'NOT ' }EXISTS (SELECT * FROM observation_sounds WHERE observation_id = o.id)", [] ]
      # @r_match << lambda { |o| (o.observation_sounds == nil || o.observation_sounds.empty?) != value }
    else
      raise TypeError, "Invalid 'sounds' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_popular value
    case value
    when true, false
      @api_params[:popular] = value
      @db_where << [ "#{ value && '' || 'NOT ' }EXISTS (SELECT * FROM observation_faves WHERE observation_id = o.id)", [] ]
      # @r_match << lambda { |o| (o.faves == nil || o.faves.empty?) != value }
      # TODO: выяснить, должны ли попадать еще и откомментированные
    else
      raise TypeError, "Invalid 'popular' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_taxon_is_active value
    case value
    when true, false
      @api_params[:taxon_is_active] = value
      @db_where << [ "o.taxon_is_active = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.taxon_is_active == value }
    else
      raise TypeError, "Invalid 'taxon_is_active' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_threatened value
    case value
    when true, false
      @api_params[:threatened] = value
      @db_where << [ "o.threatened = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.threatened == value }
    else
      raise TypeError, "Invalid 'threatened' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_verifiable value
    case value
    when true, false
      @api_params[:verifiable] = value
      @db_where << [ "o.quality_grade#{ value && '' || ' NOT' } IN ('research', 'needs_id')", [] ]
      # @r_match << lambda { |o| [ QualityGrade::RESEARCH, QualityGrade::NEEDS_ID ].include?(o.quality_grade) == value }
    else
      raise TypeError, "Invalid 'verifiable' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_licensed value
    case value
    when true, false
      @api_params[:licensed] = value
      @db_where << [ "o.license_code IS#{ value && ' NOT' || '' } NULL", [] ]
      # @r_match << lambda { |o| (o.license_code != nil) == value }
    else
      raise TypeError, "Invalid 'licensed' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_photo_licensed value
    case value
    when true, false
      @api_params[:photo_licensed] = value
      @db_where << [ "o.photo_licensed == ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.photo_licensed == value }
    else
      raise TypeError, "Invalid 'photo_licensed' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_id value
    case value
    when Integer
      @api_params[:id] = value
      @db_where << [ "o.id == ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.id == value }
    when Array
      raise TypeError, "Invalid 'id' type: #{ value.inspect }!", caller[1..] if value.any? { |v| !(Integer === v) }
      @api_params[:id] = value
      @db_where << [ "o.id IN (#{ (['?'] * value.size).join(',') })", value ]
      # @r_match << lambda { |o| value.include?(o.id) }
    else
      raise TypeError, "Invalid 'id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_not_id value
    case value
    when Integer
      @api_params[:not_id] = value
      @db_where << [ "o.id != ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.id != value }
    when Array
      raise TypeError, "Invalid 'not_id' type: #{ value.inspect }!", caller[1..] if value.any? { |v| !(Integer === v) }
      @api_params[:not_id] = value
      @db_where << [ "o.id NOT IN (#{ (['?'] * value.size).join(',') })", value ]
      # @r_match << lambda { |o| !value.include?(o.id) }
    else
      raise TypeError, "Invalid 'not_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_license value
    if Array === value
      value = value.map { |v| LicenseCode::parse(value) }
    else
      value = LicenseCode::parse(value)
    end
    case value
    when LicenseCode
      @api_params[:license] = value
      @db_where << [ "o.license_code = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.license_code == value }
    when Array
      @api_params[:license] = value
      @db_where << [ "o.license_code IN (#{ (['?'] * value.size).join(',') })", value.map(&:to_db) ]
      # @r_match << lambda { |o| value.include?(o.license_code) }
    else
      raise TypeError, "Invalid 'license' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_photo_license value
    if Array === value
      value = value.map { |v| LicenseCode::parse(value) }
    else
      value = LicenseCode::parse(value)
    end
    case value
    when LicenseCode
      @api_params[:photo_license] = value
      debug "DB selector is not implemented..."
      # Здесь отсутствие выбора для БД непринципиально — фильтрация затем происходит на уровне приложения
      @r_match << lambda { |o| o.photos != nil && o.photos.any? { |p| p.license_code == value } }
    when Array
      @api_params[:photo_license] = value
      debug "DB selector is not implemented..."
      @r_match << lambda { |o| o.photos != nil && o.photos.any? { |p| value.include?(p.license_code) } }
    else
      raise TypeError, "Invalid 'photo_license' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_sound_license value
    if Array === value
      value = value.map { |v| LicenseCode::parse(value) }
    else
      value = LicenseCode::parse(value)
    end
    case value
    when LicenseCode
      @api_params[:sound_license] = value
      debug "DB selector is not implemented..."
      # Здесь отсутствие выбора для БД непринципиально — фильтрация затем происходит на уровне приложения
      @r_match << lambda { |o| o.sounds != nil && o.sounds.any? { |s| s.license_code == value } }
    when Array
      @api_params[:sound_license] = value
      debug "DB selector is not implemented..."
      @r_match << lambda { |o| o.sounds != nil && o.sounds.any? { |s| value.include?(s.license_code) } }
    else
      raise TypeError, "Invalid 'sound_license' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_place_id value
    case value
    when Integer
      @api_params[:place_id] = value
      @db_where << [ "EXISTS (SELECT * FROM observation_places WHERE observation_id = o.id AND place_id = ?)", [ value.to_db ] ]
      # @r_match << lambda { |o| o.places != nil && o.places.any? { |p| p.id == value } }
    when Array
      @api_params[:place_id] = value
      @db_where << [ "EXISTS (SELECT * FROM observation_places WHERE observation_id = o.id AND place_id IN (#{ (['?'] * value.size).join(',') }))", value ]
      # debug "DB selector for 'place_id' arrays is not implemented..."
      # # Здесь тоже полагаемся на постфильтрацию приложением
      # @r_match << lambda { |o| o.places != nil && o.places.any? { |p| value.include?(p.id) } }
    else
      raise TypeError, "Invalid 'place_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_project_id value
    case value
    when Integer
      @api_params[:project_id] = value
      @db_where << [ "EXISTS(SELECT * FROM project_observations WHERE observation_id = o.id AND project_id = ?) OR EXISTS(SELECT * FROM observation_projects WHERE observation_id = o.id AND project_id = ?)", [ value, value ] ]
      # debug "DB selector for 'project_id' is not implemented..."
      # # Здесь используем только постфильтрацию из-за необходимости обрабатывать slug
      # @r_match << lambda { |o| o.projects != nil && o.projects.any? { |p| p.id == value } ||
      #                          o.cached_projects != nil && o.cached_projects.any? { |p| p.id == value } }
    when Array
      value = value.map do |v|
        case v
        when Integer, Symbol
          v
        when String
          v.intern
        else
          raise TypeError, "Invalid 'project_id' type: #{ value.inspect }!", caller[1..]
        end
      end
      @api_params[:project_id] = value
      @db_where << [ "EXISTS(SELECT * FROM project_observations WHERE observation_id = o.id AND project_id IN (#{ (['?'] * value.size).join(',') })) OR EXISTS(SELECT * FROM observation_projects WHERE observation_id = o.id AND project_id IN (#{ (['?'] * value.size).join(',') }))", value + value ]
      # debug "DB selector for 'project_id' is not implemented..."
      # @r_match << lambda { |o| o.projects != nil && o.projects.any? { |p| value.include?(p.id) } ||
      #                          o.cached_projects != nil && o.cached_projects.any? { |p| value.include?(p.id) } }
    else
      raise TypeError, "Invalid 'project_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_place value
    id_value = case value
    when Place
      value.id
    when Array
      value.map do |v|
        case v
        when Place
          v.id
        else
          raise TypeError, "Invalid 'place' type: #{ value.inspect }!", caller[1..]
        end
      end
    else
      raise TypeError, "Invalid 'place' type: #{ value.inspect }!", caller[1..]
    end
    parse_place_id id_value
  end

  private def parse_project value
    id_value = case value
    when Project
      value.id
    when Array
      value.map do |v|
        case v
        when Project
          v.id
        else
          raise TypeError, "Invalid 'project' type: #{ value.inspect }!", caller[1..]
        end
      end
    else
      raise TypeError, "Invalid 'project' type: #{ value.inspect }!", caller[1..]
    end
    parse_project_id id_value
  end

  private def parse_rank value
    # TODO: переработать и убрать data из хранилища
    rank = case value
    when Rank
      value
    when Symbol
      Rank[value]
    when String
      Rank::parse(value)
    when Integer
      Rank.select { |r| r.data == value }
    when Array
      value.map do |v|
        case v
        when Rank
          v
        when Symbol
          Rank[v]
        when String
          Rank::parse(v)
        when Integer
          Rank.select { |r| r.data == value }
        else
          raise TypeError, "Invalid 'rank' type: #{ value.inspect }!", caller[1..]
        end
      end.flatten
    when Range
      min = value.begin
      max = value.end
      r_min = case min
      when nil
        nil
      when Rank
        min
      when Symbol
        Rank[min]
      when String
        Rank::parse(min)
      when Integer
        Rank.find { |r| r.data <= min }
        # TODO: Подумать на предмет максимальной корректности. Но скорее всего не нужно.
      else
        raise TypeError, "Invalid 'rank' type: #{ value.inspect }!", caller[1..]
      end
      r_max = case max
      when nil
        nil
      when Rank
        max
      when Symbol
        Rank[max]
      when String
        Rank::parse(max)
      when Integer
        Rank.find { |r| r.data <= max }
      else
        raise TypeError, "Invalid 'rank' type: #{ value.inspect }!", caller[1..]
      end
      Range::new r_min, r_max, value.exclude_end?
    else
      raise TypeError, "Invalid 'rank' type: #{ value.inspect }!", caller[1..]
    end
    case rank
    when Rank
      @api_params[:rank] = rank
      @db_where << [ "o.rank_name = ?", [ rank.name ] ]
      # @r_match << lambda { |o| o.rank == rank }
    when Array
      @api_params[:rank] = rank
      @db_where << [ "o.rank_name IN (#{(['?'] * rank.size).join(',')})", rank.map(&:name) ]
      # @r_match << lambda { |o| rank.include?(o.rank) }
    when Range
      min = rank.begin
      max = rank.end
      if min
        @api_params[:hrank] = min
        @db_where << [ "o.rank_data <= ?", [ min.data ] ]
        # @r_match << lambda { |o| o.rank >= min }
      end
      if max
        @api_params[:lrank] = max
        @db_where << [ "o.rank_data >= ?", [ max.data ] ]
        # @r_match << lambda { |o| o.rank <= max }
      end
    else
      raise TypeError, "Invalid rank value: #{ rank.inspect }!"
    end
  end

  private def parse_hrank value
    parse_rank(value..)
  end

  private def parse_lrank value
    parse_rank(..value)
  end

  private def parse_taxon_id value
    case value
    when Integer
      @api_params[:taxon_id] = value
      @db_where << [ "EXISTS (SELECT * FROM observation_ident_taxa WHERE observation_id = o.id AND taxon_id = ?)", [ value ] ]
      # @r_match << lambda { |o| o.ident_taxon_ids.include?(value) }
    when Array
      @api_params[:taxon_id] = value
      @db_where << [ "EXISTS (SELECT * FROM observation_ident_taxa WHERE observation_id = o.id AND taxon_id IN (#{(['?'] * value.size).join(',')}))", value ]
      # @r_match << lambda { |o| value.any? { |v| o.ident_taxon_ids.include?(v) } }
    else
      raise TypeError, "Invalid 'taxon_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_taxon value
    case value
    when Taxon
      parse_taxon_id value.id
    when Array
      ids = value.map do |v|
        case v
        when Taxon
          v.id
        else
          raise TypeError, "Invalid 'taxon' type: #{ value.inspect }!", caller[1..]
        end
      end
      parse_taxon_id ids
    else
      raise TypeError, "Invalid 'taxon' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_without_taxon_id value
    case value
    when Integer
      @api_params[:taxon_id] = value
      @db_where << [ "NOT EXISTS (SELECT * FROM observation_ident_taxa WHERE observation_id = o.id AND taxon_id = ?)", [ value ] ]
      # @r_match << lambda { |o| o.ident_taxon_ids.include?(value) }
    when Array
      @api_params[:taxon_id] = value
      @db_where << [ "NOT EXISTS (SELECT * FROM observation_ident_taxa WHERE observation_id = o.id AND taxon_id IN (#{(['?'] * value.size).join(',')}))", value ]
      # @r_match << lambda { |o| value.any? { |v| o.ident_taxon_ids.include?(v) } }
    else
      raise TypeError, "Invalid 'taxon_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_without_taxon value
    case value
    when Taxon
      parse_taxon_id value.id
    when Array
      ids = value.map do |v|
        case v
        when Taxon
          v.id
        else
          raise TypeError, "Invalid 'without_taxon' type: #{ value.inspect }!", caller[1..]
        end
      end
      parse_without_taxon_id ids
    else
      raise TypeError, "Invalid 'without_taxon' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_taxon_name value
    case value
    when String
      @api_params[:taxon_name] = value
      debug "DB selector for 'taxon_name' is not implemented..."
      small = value.downcase
      @r_match << lambda { |o| o.taxon.name.downcase == small || o.taxon.preferred_common_name&.downcase == small || o.taxon.english_common_name&.downcase == small }
    when Array
      @api_params[:taxon_name] = value
      debug "DB selector for 'taxon_name' is not implemented..."
      small = value.map(&:downcase)
      @r_match << lambda { |o| small.any? { |n| o.taxon.name.downcase == n || o.taxon.preferred_common_name&.downcase == n || o.taxon.english_common_name&.downcase == n } }
    else
      raise TypeError, "Invalid 'taxon_name' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_user_login value
    case value
    when Integer
      @api_params[:user_id] = value
      @db_where << [ "o.user_id == ?", [ value ] ]
      # @r_match << lambda { |o| o.user_id == value }
    when String, Symbol
      @api_params[:user_login] = value
      @db_where << [ "EXISTS (SELECT * FROM users WHERE id = o.user_id AND login = ?)", [ value.to_db ] ]
      # @r_match << lambda { |o| o.user.login == value.to_s }
    when Array
      @api_params[:user_id] = value
      debug "DB selector for 'user_id/user_login' arrays is not implemented..."
      @r_match << lambda { |o| value.any? { |v| o.user.id == v || o.user.login == v.to_s } }
    else
      raise TypeError, "Invalid 'user_id/user_login' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_user value
    case value
    when User
      parse_user_login value.id
    else
      raise TypeError, "Invalid 'user' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_ident_user_id value
    case value
    when Integer
      @api_params[:ident_user_id] = value
      @db_where << [ "EXISTS (SELECT * FROM identifications WHERE observation_id = o.id AND user_id = ?)", [ value ] ]
      # @r_match << lambda { |o| o.identification.any? { |i| i.user_id == value } }
    else
      raise TypeError, "Invalid 'ident_user_id' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_ident_user value
    case value
    when User
      parse_ident_user_id value.id
    else
      raise TypeError, "Invalid 'ident_user' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_day value
    case value
    when Integer, String
      value = value.to_i
      @api_params[:day] = value
      @db_where << [ "o.day = ?", [ value ] ]
      # @r_match << lambda { |o| o.day == value }
    when Array
      value = value.map(&:to_i)
      @api_params[:day] = value
      @db_where << [ "o.day IN (#{(['?'] * value.size).join(',')})", value ]
      # @r_match << lambda { |o| value.include?(o.day) }
    else
      raise TypeError, "Invalid 'day' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_month value
    case value
    when Integer, String
      value = value.to_i
      @api_params[:month] = value
      @db_where << [ "o.month = ?", [ value ] ]
      # @r_match << lambda { |o| o.month == value }
    when Array
      value = value.map(&:to_i)
      @api_params[:month] = value
      @db_where << [ "o.month IN (#{(['?'] * value.size).join(',')})", value ]
      # @r_match << lambda { |o| value.include?(o.month) }
    else
      raise TypeError, "Invalid 'month' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_year value
    case value
    when Integer, String
      value = value.to_i
      @api_params[:year] = value
      @db_where << [ "o.year = ?", [ value ] ]
      # @r_match << lambda { |o| o.year == value }
    when Array
      value = value.map(&:to_i)
      @api_params[:year] = value
      @db_where << [ "o.year IN (#{(['?'] * value.size).join(',')})", value ]
      # @r_match << lambda { |o| value.include?(o.year) }
    else
      raise TypeError, "Invalid 'year' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_d1 value
    case value
    when Date
      @api_params[:d1] = value
      @db_where << [ "o.observed_on >= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.observed_on >= value }
    else
      raise TypeError, "Invalid 'd1' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_d2 value
    case value
    when Date
      @api_params[:d2] = value
      @db_where << [ "o.observed_on <= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.observed_on <= value }
    else
      raise TypeError, "Invalid 'd2' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_observed_on value
    case value
    when Date
      @api_params[:observed_on] = value
      @db_where << [ "o.observed_on = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.observed_on == value }
    when Range
      min = value.begin
      max = value.end
      parse_d1 min if min
      parse_d2 max if max
    else
      raise TypeError, "Invalid 'observed_on/date' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_created_d1 value
    case value
    when Time
      @api_params[:created_d1] = value
      @db_where << [ "o.created_at >= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.created_at >= value }
    when Date
      @api_params[:created_d1] = value
      @db_where << [ "o.created_at >= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.created_at >= value.to_time }
    else
      raise TypeError, "Invalid 'created_d1' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_created_d2 value
    case value
    when Time
      @api_params[:created_d2] = value
      @db_where << [ "o.created_at <= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.created_at <= value }
    when Date
      @api_params[:created_d2] = value
      @db_where << [ "o.created_at <= ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.created_at <= value.to_time }
    else
      raise TypeError, "Invalid 'created_d2' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_created_on value
    case value
    when Date, Time
      value = value.to_date
      @api_params[:created_on] = value
      @db_where << [ "o.created_at >= ? AND o.created_at < ?", value.to_db, value.to_db + 24 * 60 * 60 ]
      # @r_match << lambda { |o| o.created_at.to_date == value }
    when Range
      min = value.begin
      max = value.end
      parse_created_d1 min if min
      parse_created_d2 max if max
    else
      raise TypeError, "Invalid 'created_on' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_geoprivacy value
    case value
    when GeoPrivacy
      @api_params[:geoprivacy] = value
      @db_where << [ "o.geoprivacy = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.geoprivacy == value }
    when Array
      @api_params[:geoprivacy] = value
      @db_where << [ "o.geoprivacy IN (#{ (['?'] * value.size).join(',') })", value.map(&:to_db) ]
      # @r_match << lambda { |o| value.include?(o.geoprivacy) }
    else
      raise TypeError, "Invalid 'geoprivacy' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_taxon_geoprivacy value
    case value
    when GeoPrivacy
      @api_params[:taxon_geoprivacy] = value
      @db_where << [ "o.taxon_geoprivacy = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.taxon_geoprivacy == value }
    when Array
      @api_params[:taxon_geoprivacy] = value
      @db_where << [ "o.taxon_geoprivacy IN (#{ (['?'] * value.size).join(',') })", value.map(&:to_db) ]
      # @r_match << lambda { |o| value.include?(o.taxon_geoprivacy) }
    else
      raise TypeError, "Invalid 'taxon_geoprivacy' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def iconic_taxa value
    case value
    when IconicTaxa
      @api_params[:iconic_taxa] = value
      warning "DB selector for 'iconic_taxa' is not implemented..."
      # Тут по идее надо по всем идентификациям брать...
      @r_match << lambda { |o| o.taxon.iconic_taxon_name == value }
    when Array
      @api_params[:iconic_taxa] = value
      warning "DB selector for 'iconic_taxa' is not implemented..."
      @r_match << lambda { |o| value.include?(o.taxon.iconic_taxon_name) }
    else
      raise TypeError, "Invalid 'iconic_taxa' type: #{ value.inspect }!", caller[1..]
    end
  end

  private def parse_quality_grade value
    case value
    when QualityGrade
      @api_params[:quality_grade] = value
      @db_where << [ "o.quality_grade = ?", [ value.to_db ] ]
      # @r_match << lambda { |o| o.quality_grade == value }
    when Array
      @api_params[:quality_grade] = value
      @db_where << [ "o.quality_grade IN (#{ (['?'] * value.size).join(',') })", value.map(&:to_db) ]
      # @r_match << lambda { |o| value.include?(o.quality_grade) }
    else
      raise TypeError, "Invalid 'quality_grade' type: #{ value.inspect }!", caller[1..]
    end
  end

  def initialize **params

    @api_params = {}
    @db_where = []
    @r_match = []

    debug "Initializing Query: #{ params.inspect }"

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
      when :endemic
        parse_endemic value
      when :introduced
        parse_introduced value
      when :native
        parse_native value
      when :mappable
        parse_mappable value
      when :geo, :location
        parse_location value
      when :lat, :lng, :radius
        raise ArgumentError, "Query parameter '#{ key }' is unsupported. Use 'location' with Radius value instead!", caller
      when :nelat, :nelng, :swlat, :swlng
        raise ArgumentError, "Query parameter '#{ key }' is unsupported. Use 'location' with Sector value instead!", caller
      when :popular
        parse_popular value
      when :photos
        parse_photos value
      when :sounds
        parse_sounds value
      when :taxon_is_active
        parse_taxon_is_active value
      when :threatened
        parse_threatened value
      when :verifiable
        parse_verifiable value
      when :licensed
        parse_licensed value
      when :photo_licensed
        parse_photo_licensed value
      when :id
        parse_id value
      when :not_id
        parse_not_id value
      when :license
        parse_license value
      when :photo_license
        parse_photo_license value
      when :sound_license
        parse_sound_license value
      when :place_id
        parse_place_id value
      when :place
        parse_place value
      when :project_id
        parse_project_id value
      when :project
        parse_project value
      when :rank
        parse_rank value
      when :hrank
        parse_hrank value
      when :lrank
        parse_lrank value
      when :taxon_id
        parse_taxon_id value
      when :taxon
        parse_taxon value
      when :without_taxon_id
        parse_without_taxon_id value
      when :without_taxon
        parse_without_taxon value
      when :taxon_name
        parse_taxon_name value
      when :user_id, :user_login
        parse_user_login value
      when :user
        parse_user value
      when :ident_user_id
        parse_ident_user_id value
      when :ident_user
        parse_ident_user value
      when :day
        parse_day value
      when :month
        parse_month value
      when :year
        parse_year value
      when :d1
        parse_d1 value
      when :d2
        parse_d2 value
      when :observed_on, :date
        parse_observed_on value
      when :created_d1
        parse_created_d1 value
      when :created_d2
        parse_created_d2 value
      when :created_on, :created_at
        parse_created_on value
      when :geoprivacy
        parse_geoprivacy value
      when :taxon_geoprivacy
        parse_taxon_geoprivacy value
      when :iconic_taxa
        parse_iconic_taxa value
      when :quality_grade
        parse_quality_grade value
      # TODO: other properties
      # when :out_of_range not supported
      # when :pcid not supported
      # when :ofv_datatype not supported
      # TODO: when :site_id not supported
      # TODO: when :term_id not supported
      # TODO: when :term_value_id not supported
      # when :without_term_id not supported
      # when :without_term_value_id not supported
      # TODO: when :with_term_value_id not supported
      # when :apply_project_rules_for
      # TODO: when :cs
      # TODO: when :csa
      # TODO: when :sci
      # when :identifications
      # when :list_id
      # when :not_in_project
      # when :not_matching_project_rules_for
      # when :q
      # when :search_on
      else
        raise ArgumentError, "Query parameter '#{ key }' is unknown or not supported!", caller
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
          return false unless array_covers(own_param, value.split(','))
        else
          return false unless array_covers(value.split(','), own_param)
        end
      when Date
        value = Date::parse value
        if key.end_with?('1')
          return false unless own_param <= value
        elsif key.end_with?('2')
          return false unless own_param >= value
        end
      else
        return false unless own_param.to_query == value
      end
    end
    return true
    # TODO: обрабатывать вложенность таксонов, мест и проектов, а также координат.
  end

  def api_query
    # TODO: подумать о сортировке массивов
    @api_params.map { |k, v| "#{ k }=#{ v.to_query }" }.sort.join("&")
  end

  def db_where
    sql = []
    sql_args = []
    @db_where.each do |item|
      sql << item[0]
      sql_args << item[1]
    end
    [ sql.map { |s| "(#{ s })" }.join(' AND '), sql_args.flatten ]
  end

  def match? observation
    @r_match.all? { |m| m === observation }
  end

  def === observation
    match? observation
  end

  def observations
    # $SHOW_SAVES = false
    request = nil
    current_time = nil
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
        actuals = Request::from_db_rows(DB.execute("SELECT * FROM requests WHERE time >= ?", actual_time.to_db)).select { |rq| self.in?(rq.query) }
      end
      if actuals.empty? || mode == UpdateMode::FORCE
        # 2. Ищем чего бы обновить
        request = Request::from_db_rows(DB.execute("SELECT * FROM requests WHERE query = ?", api_query)).first
        updated_since = nil
        if request == nil
          query_string = api_query
          project_id = @api_params[:project_id]
          project_id = nil unless Integer === project_id
          request = Request::create query_string, project_id
          request.save
        else
          updated_since = request.time if mode != UpdateMode::RELOAD
        end
        params = @api_params.dup
        params[:updated_since] = updated_since if updated_since && updated_since != Time::at(0)
        # request.save
        olinks = []
        tt = nil
        cc = 0
        current_time = Time::new
        API::query(:observations, **params) do |json, total|
          tt ||= total
          cc += 1
          pc = cc * 100 / tt
          td = (Time::new - current_time) / cc
          te = (td * (tt - cc)).to_i
          pe = Period::make seconds: te
          pt = Period::make seconds: (Time::new - current_time).to_i
          Status::status format("%7d  << %7d : %3d%% : %9s  << %9s", cc, tt, pc, pt.to_hs, pe.to_hs)
          # if (cc % 100) == 0
          #   $stderr.puts ''
          # end
          obs = Observation::parse json
          olinks << "INSERT OR REPLACE INTO request_observations (request_id, observation_id) VALUES (#{ request.id }, #{obs.id});"
          # DB.execute "INSERT OR REPLACE INTO request_observations (request_id, observation_id) VALUES (?, ?);", request.id, obs.id
        end
        DB.execute_batch olinks.join("\n")
        # Считываем свежедобаленное
        # TODO: разобраться с удалением устаревшего
        # NEED: разобраться с частичной загрузкой — большие проекты грузятся недопустимо долго
        #       возможно, стоит запараллелить обработку
        request = Request::read(request.id).first
      end
    end
    # TODO: разобраться, где тупня
    # $SHOW_SAVES = true
    sql, sql_args = db_where
    result = Observation::from_db_rows(DB.execute("SELECT * FROM observations o#{ sql.empty? && '' || ' WHERE ' }#{ sql };", *sql_args))
    if !@r_match.empty?
      result = result.filter { |o| self.match?(o) }
    end
    if request != nil
      request.update do
        request.time = current_time if current_time
      end
      request.save
    end
    Status::status "Some queries done."
    result
  end

end
