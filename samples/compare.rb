# frozen_string_literal: true

require 'inat/app/info'
require 'inat/report/table'
require 'inat/data/sets/listers'

class Compare

  include TableDSL

  def initialize name, inner_list, outer_lists
    @name = name
    @inner = inner_list
    @places = outer_lists.keys
    @outer_lists = outer_lists
    @outer = outer_lists.values.reduce List::new([], Listers::SPECIES), :+
  end

  private def neighbours_ul
    neighbours_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Место', data: :place
      column 'Виды', width: 6, align: :right, data: :species
      column 'Наблюдения', width: 6, align: :right,  data: :observations
    end
    neighbour_rows = []
    @outer_lists.each do |place, list|
      neighbour_rows << {
        place: place,
        species: list.count,
        observations: list.observation_count
      }
    end
    neighbour_rows << {
      line_no: '',
      place: '',
      species: "<b>#{ @outer.count }</b>",
      observations: "<b>#{ @outer.observation_count }</b>"
    }
    neighbours_table << neighbour_rows
    neighbours_table.to_html
  end

  # TODO: вынести связку списка и наблюдателей отдельно (см. историю)
  private def uniqs_section
    uniqs = @inner - @outer
    return '<i>«Уникальных», т.е. не найденных у соседей, таксонов не обнаружено.</i>' if uniqs.empty?
    uniqs_table = table do
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
    # Готовим данные. Можно было бы тупо замапить, но нужны ссылки на наблюдателей...
    # Разворачиваем список и сворачиваем по юзерам
    by_users = uniqs.to_dataset.to_list Listers::USER
    user_rows = []
    by_users.each do |ds|
      ls = ds.to_list Listers::SPECIES
      user = ds.object
      user_rows << {
        user: user,
        anchor: "uniq-user-#{ user.login }",
        species: ls.count,
        observations: ds.count
      }
    end
    user_rows.sort_by! { |row| row[:species] }.reverse!
    # Основную таблицу формируем после таблицы наблюдателей, чтобы нормально ссылаться.
    uniq_rows = []
    uniqs.each do |ds|
      taxon = ds.object
      observations = []
      ds.each do |obs|
        user = obs.user
        anchor = "uniq-user-#{ user.login }"
        observations << "#{ obs }<sup><a href=\"\##{ anchor }\">#{ user_rows.index { |i| i[:user] == user } + 1 }</a></sup>"
      end
      uniq_rows << { taxon: taxon, observations: observations.join(', ') }
    end
    uniqs_table << uniq_rows
    observers_table << user_rows
    result = []
    result << '<h2>«Уники»</h2>'
    result << ''
    result << 'Таксоны, не найденные ни у кого из соседей.'
    result << ''
    result << uniqs_table.to_html
    result << ''
    result << '<h4>Наблюдатели «уников»</h4>'
    result << ''
    result << observers_table.to_html
    result.join "\n"
  end

  private def wanted_section
    # Выбираем таксоны, отсутствующие в домашней выборке и имеющие не менее двух наблюдений у соседей.
    # Важно: результат не List, а массив датасетов.
    wanted = (@outer - @inner).filter { |ds| ds.count >= 2 }
    return '<i>Не найдено таксонов, наблюдаемых только у соседей.</i>' if wanted.empty?
    wanted_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Таксон', data: :taxon
      column 'Наблюдения', data: :observations
    end
    # Нам нужно получить топ-50 по количеству наблюдений, а затем отсортировать дефолтной сортировкой.
    top_wanted = wanted.sort_by { |ds| ds.count }.reverse.take(50).sort_by { |ds| ds.object.sort_key }
    wanted_rows = top_wanted.map { |ds| { taxon: ds.object, observations: ds.observations.map { |o| "#{ o }" }.join(', ') } }
    wanted_table << wanted_rows
    result = []
    result << '<h2>«Разыскиваются»</h2>'
    result << ''
    if wanted.count > 50
      result << "Топ-50 (из #{ wanted.count }) таксонов, обнаруженных у соседей, но пока(?) не найденных здесь."
    else
      result << 'Таксоны, обнаруженные у соседей, но пока(?) не найденные здесь.'
    end
    result << ''
    result << wanted_table.to_html
    result.join "\n"
  end

  private def generate
    result = []
    result << '<h1>Сравнение с соседями</h1>'
    result << ''
    result << 'Сравнение выполненялость со следующими территориями:'
    result << ''
    result << neighbours_ul
    result << ''
    result << uniqs_section
    result << ''
    result << wanted_section
    result << ''
    result << '<hr>'
    result << "<small>Отчет сгенерирован посредством <a href=\"#{ AppInfo::HOMEPAGE }\">INat::Get v#{ AppInfo::VERSION }</a>.</small>"
    result
  end

  def write file = nil
    @output ||= generate
    case file
    when nil
      File.write "#{ @name } - Сравнение с соседями.htm", @output.join("\n")
    when String
      File.write file, @output.join("\n")
    when IO
      file.writet @output.join("\n")
    end
  end

end
