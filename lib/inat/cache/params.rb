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
        else
          raise TypeError, "Invalid 'rank' value: #{ value.inspect }!"
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
      end
    end
    [ api_params, db_params, r_params ]
  end

  module_function :prepare_params

end
