
require 'inat/report/report_dsl'

class UserRep

  include INat::App::Task::DSL
  include INat::Report::Table::DSL
  include INat::Report::DSL
  include INat::App::Info
  include INat::Report
  include INat::Data::Types

  User = INat::Entity::User

  def initialize login, finish
    @user = User::by_login login
    @finish = finish
  end

  private def season
    @finish.year
  end

  private def gen_seasons
    seasons_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Сезон', data: :year
      column 'Все набл.', width: 6, align: :right, data: :all_count
      column 'ИС', width: 6, align: :right, data: :res_count
      column 'Виды', width: 6, align: :right, data: :species
      column 'Новые', width: 6, align: :right, data: :news
    end
    last_year = Period::Year[@finish]
    dataset = select user_id: @user.id, date: (.. @finish)
    seasons = dataset.to_list Listers::YEAR
    season_rows = []
    olds = List::zero Listers::SPECIES
    @news = List::zero Listers::SPECIES
    year = nil
    seasons.each do |ds|
      year = ds.object
      res_ds = ds.where { |o| o.quality_grade == QualityGrade::RESEARCH }
      res_ls = res_ds.to_list Listers::SPECIES
      @news = res_ls - olds
      olds = olds + res_ls
      season_rows << { year: year, all_count: ds.count, res_count: res_ds.count, species: res_ls.count, news: @news.count }
    end
    if last_year != year
      season_rows << { year: last_year, all_count: 0, res_count: 0, species: 0, news: 0 }
      @news = List::zero Listers::SPECIES
    end
    season_rows.last[:style] = 'font-size:110%;'
    rr_ds = dataset.where { |o| o.quality_grade == QualityGrade::RESEARCH }
    rr_ls = rr_ds.to_list Listers::SPECIES
    season_rows << { line_no: '', all_count: dataset.count, res_count: rr_ds.count, species: rr_ls.count, style: 'font-weight: bold;' }
    seasons_table << season_rows
    seasons_table.to_html
  end

  private def gen_signature
    "\n<hr>\n\n<small>Отчет сгенерирован посредством <a href=\"https://github.com/shikhalev/inat-get\">INat::Get v#{ VERSION }</a></small>"
  end

  private def gen_news
    result = []
    if @news.count > 0
      result << "<h2>Новинки</h2>"
      result << ""
      result << species_table(@news).to_html
    end
    result.join "\n"
  end

  def generate_history
    result = []
    result << "<h1>Итоги сезона #{ season }</h1>"
    result << ""
    result << "<h2>История</h2>"
    result << ""
    result << gen_seasons
    result << ""
    result << gen_news
    result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_history file = nil
    output = generate_history
    case file
    when nil
      File.write "#{ @user.login }-История.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

end
