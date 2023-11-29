# frozen_string_literal: true

require_relative 'table'

module INat::Report::DSL

  include INat
  include INat::Report
  include INat::Report::Table::DSL

  private def class_title object, is_observer: true
    case object
    when Entity::Taxon
      'Таксон'
    when Entity::Place
      'Территория'
    when Entity::Project
      'Проект'
    when Entity::User
      if is_observer
        'Наблюдатель'
      else
        'Пользователь'
      end
    when Report::Period
      'Период'
    else
      'Объект'
    end
  end

  def species_table list, observers: false, details: true
    raise ArgumentError, 'Unconsistent flags!' if observers && !details
    object_title = class_title list.first.object
    species = table do
      column '#', width: 3, align: :right, data: :line_no
      column object_title, data: :object
      if details
        column 'Наблюдения', data: :observations
      else
        column 'Наблюдения', data: :observations, width: 6, align: :right
      end
    end
    users = nil
    user_rows = []
    if observers
      @@prefix ||= 0
      @@prefix += 1
      users = table do
        column '#', width: 3, align: :right, data: :line_no
        column 'Наблюдатель', data: :user
        column 'Виды', width: 6, align: :right, data: :species
        column 'Наблюдения', width: 6, align: :right, data: :observations
      end
      by_user = list.to_dataset.to_list Listers::USER
      by_user.each do |ds|
        ls = ds.to_list Listers::SPECIES
        user = ds.object
        user_rows << { user: user, anchor: "#{ @@prefix }-user-#{ user.id }", species: ls.count, observations: ds.count }
      end
      user_rows.sort_by! { |row| -row[:species] }
      users << user_rows
    end
    species_rows = []
    list.each do |ds|
      observations = if details
        if observers
          ds.observations.map { |o| "#{ o }<sup><a href=\"\##{ @@prefix }-user-#{ o.user.id }\">#{ user_rows.index { |row| row[:user] == o.user } }</a></sup>" }
        else
          ds.observations.map(&:to_s)
        end
      else
        [ ds.count.to_s ]
      end
      species_rows << { object: ds.object, observations: observations.join(', ') }
    end
    species << species_rows
    if observers
      [ species, users ]
    else
      species
    end
  end

  LAST_STYLE = 'font-size:110%;'
  SUMMARY_STYLE = 'font-weight:bold;'

  def history_table list, news: true, summary: true, base_link: nil, last: nil, extras: false, last_style: LAST_STYLE, summary_style: SUMMARY_STYLE
    object_title = class_title list.first.object, is_observer: false
    history = table do
      column '#', width: 3, align: :right, data: :line_no
      column object_title, data: :object
      column 'Наблюдения', width: 6, align: :right, data: :observations
      column 'Виды', width: 6, align: :right, data: :species
      if news
        column 'Новые', width: 6, align: :right, data: :news
      end
    end
    history_rows = []
    last_object = nil
    last_ds = nil
    last_ls = nil
    delta = nil
    if news || summary
      base_ls = List::zero Listers::SPECIES
    end
    list.each do |ds|
      last_object = ds.object
      last_ds = ds
      last_ls = ds.to_list Listers::SPECIES
      row = { observations: last_ds.count, species: last_ls.count }
      if base_link && last_object.respond_to?(:query_params)
        link = base_link + '&' + last_object.query_params
        row[:object] = "<a href=\"#{ link }\">#{ last_object }</a>"
      else
        row[:object] = last_object
      end
      if news || summary
        delta = last_ls - base_ls
        base_ls += last_ls
        row[:news] = delta.count
      end
      history_rows << row
    end
    if last && last != last_object
      row = { object: last, observations: 0, species: 0 }
      if news
        row[:news] = 0
        delta = List::zero Listers::SPECIES
        last_object = last
        last_ds = DataSet::zero
        last_ls = List::zero Listers::SPECIES
      end
      history_rows << row
    end
    history_rows.last[:style] = last_style if last_style
    if summary
      # Почему base_ls, а не list?
      #   1. list в некоторых случаях может быть не List, а просто массив DataSet с заполненным object.
      #   2. Даже в базовом случае list сформирован не по видам.
      row = { line_no: '', observations: base_ls.observation_count, species: base_ls.count }
      row[:style] = summary_style if summary_style
      history_rows << row
    end
    history << history_rows
    if extras
      [ history, last_ds, delta ]
    else
      history
    end
  end

  # Вариант history_table с другими предустановками.
  def summary_table list, extras: false, summary_style: SUMMARY_STYLE
    history_table list, news: false, summary: true, base_link: nil, last: nil, extras: extras, last_style: nil, summary_style: summary_style
  end

  # TODO: разобраться с разными count в разных контекстах.
  def rating_table list, limit: 1, count: 3, details: true, key: :species, summary: false
    object_title = class_title list.first&.object
    rating = table do
      column '#', width: 3, align: :right, data: :line_no
      column object_title, data: :object
      column 'Виды', width: 6, align: :right, data: :species
      if details
        column 'Наблюдения', data: :observations
      else
        column 'Наблюдения', width: 6, align: :right, data: :observations
      end
    end
    rating_rows = []
    list.each do |ds|
      ls = ds.to_list Listers::SPECIES
      row = { object: ds.object, species: ls.count, count: ds.count }
      if details
        row[:observations] = ds.observations.map(&:to_s).join(', ')
      else
        row[:observations] = ds.count
      end
      rating_rows << row
    end
    size = rating_rows.size
    key = :count if key == :observations
    if limit
      rating_rows.filter! { |row| row[key] >= limit }
    end
    rating_rows.sort_by! { |row| -row[key] }
    if count
      rating_rows = rating_rows.take(count)
    end
    if summary
      full_ls = List === list ? list : list.reduce(DataSet::zero, :|).to_list
      rating_rows << { line_no: '', species: full_ls.count, count: full_ls.observation_count }
    end
    rating << rating_rows
    if count
      [ rating, size ]
    else
      rating
    end
  end

  module_function :species_table, :history_table, :summary_table, :rating_table

end
