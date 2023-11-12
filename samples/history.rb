# frozen_string_literal: true

require 'inat/app/info'
require 'inat/report/table'
require 'inat/data/sets/listers'

class History

  include TableDSL

  def initialize name, dataset, top_count: 10, top_limit: 10
    @name = name
    @dataset = dataset
    @top_count = top_count
    @top_limit = top_limit
    @list = dataset.to_list Listers::SPECIES
    @last = nil
    @delta = nil
    @last_year = nil
    @years = nil
  end

  private def history
    years_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Год', data: :year
      column 'Наблюдения', width: 6, align: :right,  data: :observations
      column 'Виды', width: 6, align: :right, data: :species
      column 'Новые', width: 6, align: :right, data: :news
    end
    @years = @dataset.to_list Listers::YEAR
    olds = List::new [], Listers::SPECIES
    year_rows = []
    @years.each do |ds|
      ls = ds.to_list Listers::SPECIES
      @delta = ls - olds
      @last_year = ds.object
      year_rows << {
        year: "<i class=\"glyphicon glyphicon-calendar\"></i>  #{ ds.object }",
        observations: ds.count,
        species: ls.count,
        news: @delta.count
      }
      olds = olds + ls
      @last = ds
    end
    year_rows << {
      line_no: '',
      year: '',
      observations: "<b>#{ @dataset.count }</b>",
      species: "<b>#{ @list.count }</b>",
      news: ''
    }
    years_table << year_rows
    years_table.to_html
  end

  private def top source, title
    users_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Наблюдатель', data: :user
      column 'Виды', width: 6, align: :right, data: :species
      column 'Наблюдения', width: 6, align: :right,  data: :observations
    end
    users = source.to_list Listers::USER
    user_rows = []
    users.each do |ds|
      user = ds.object
      ls = ds.to_list Listers::SPECIES
      user_rows << {
        user: user,
        species: ls.count,
        observations: ds.count
      }
    end
    user_rows = user_rows.filter { |row| row[:species] >= @top_limit }.sort_by { |row| row[:species] }.reverse.take(@top_count)
    users_table << user_rows
    result = []
    if !user_rows.empty?
      result << ''
      result << "<h4>#{ title }</h4>"
      result << ''
      result << users_table.to_html
    end
    result.join "\n"
  end

  private def tops
    result = []
    result << top(@last, 'За сезон')
    result << top(@dataset, 'За всё время')
    result.join "\n"
  end

  # TODO: вынести связку списка и наблюдателей отдельно (см. сравнение с соседями)
  private def news
    return "<i>В сезоне #{ @last_year } новых таксонов не наблюдалось.</i>" if @delta.empty?
    news_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Таксон', data: :taxon
      column 'Наблюдения', data: :observations
    end
    observers_table = table do
      column '#', width: 3, align: :right, data: :line_no, marker: true
      column 'Наблюдатель', data: :user
      column 'Виды', width: 6, align: :right, data: :species
      column 'Наблюдения', width: 6, align: :right,  data: :observations
    end
    by_users = @delta.to_dataset.to_list Listers::USER
    user_rows = []
    by_users.each do |ds|
      user = ds.object
      ls = ds.to_list Listers::SPECIES
      user_rows << {
        user: user,
        anchor: "news-user-#{ user.login }",
        species: ls.count,
        observations: ds.count,
      }
    end
    user_rows.sort_by! { |row| row[:species] }.reverse!
    observers_table << user_rows
    news_rows = []
    @delta.each do |ds|
      taxon = ds.object
      observations = []
      ds.each do |obs|
        user = obs.user
        anchor = "news-user-#{ user.login }"
        observations << "#{ obs }<sup><a href=\"\##{ anchor }\">#{ user_rows.index { |i| i[:user] == user } + 1 }</a></sup>"
      end
      news_rows << { taxon: taxon, observations: observations.join(', ') }
    end
    news_table << news_rows
    result = []
    result << '<h2>Новинки</h2>'
    result << ''
    result << "Таксоны, наблюдавшиеся в сезоне #{ @last_year } впервые."
    result << ''
    result << news_table.to_html
    result << ''
    result << '<h4>Наблюдатели новинок</h4>'
    result << ''
    result << observers_table.to_html
    result.join "\n"
  end

  private def missed
    olds = @years.select { |ds| ds.object <= @last_year - 3 }.reduce(DataSet::new(nil, []), :|).to_list(Listers::SPECIES)
    news = @years.select { |ds| ds.object > @last_year - 3 }.reduce(DataSet::new(nil, []), :|).to_list(Listers::SPECIES)
    missed_list = olds - news
    return '' if missed_list.empty?
    missed_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Таксон', data: :taxon
      column 'Наблюдения', data: :observations
    end
    missed_rows = missed_list.map { |ds| { taxon: ds.object, observations: ds.observations.map { |o| "#{ o }" }.join(', ') } }
    missed_table << missed_rows
    result = []
    result << '<h2>«Потеряшки»</h2>'
    result << ''
    result << 'Ранее найденные таксоны без подтвержденных наблюдений в последние 3 сезона.'
    result << ''
    result << missed_table.to_html
    result.join "\n"
  end

  private def generate
    result = []
    result << '<h1>Итоги сезона</h1>'
    result << ''
    result << 'Здесь и далее учитываются только наблюдения исследовательского уровня, если отдельно и явно не оговорено иное.'
    result << ''
    result << '<h2>История</h2>'
    result << ''
    result << history
    result << ''
    result << '<h2>Лучшие наблюдатели</h2>'
    result << ''
    result << "Тор-#{ @top_count } наблюдателей среди тех, кто набрал не менее #{ @top_limit } видов."
    result << ''
    result << tops
    result << news
    result << missed
    result << ''
    result << '<hr>'
    result << "<small>Отчет сгенерирован посредством <a href=\"#{ AppInfo::HOMEPAGE }\">INat::Get v#{ AppInfo::VERSION }</a>.</small>"
    result
  end

  def write file = nil
    @output ||= generate
    case file
    when nil
      File.write "#{ @name } - История.htm", @output.join("\n")
    when String
      File.write file, @output.join("\n")
    when IO
      file.writet @output.join("\n")
    end
  end

end
