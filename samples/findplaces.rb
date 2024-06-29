
require 'inat/report/report_dsl'

class FindPlaces

  include INat::App::Logger::DSL

  include INat::App::Task::DSL
  include INat::Report::Table::DSL
  include INat::Report::DSL
  include INat::App::Info
  include INat::Report
  include INat::Data::Types

  Project = INat::Entity::Project
  Place   = INat::Entity::Place

  def initialize **query
    @query = query
  end

  private def gen_list
    result = []
    result << "<ul>\n"
    dataset = select **@query
    places = dataset.map { |o| o.places }.flatten.sort.uniq
    places.each do |pl|
      result << "<li>#{ pl }\n"
      projects = Project::query place_id: pl.id
      if !projects.empty?
        result << "<ul>\n"
        projects.each do |pr|
          result << "<li>#{ pr }</li>\n"
        end
        result << "</ul>"
      end
      result << "\n</li>\n"
    end
    result << "\n</ul>"
  end

  private def gen_signature
    "\n<hr>\n\n<small>Отчет сгенерирован посредством <a href=\"https://github.com/shikhalev/inat-get\">INat::Get v#{ VERSION }</a></small>"
  end

  def generate_list
    result = []
    result << gen_list
    result << ''
    result << gen_signature
    result.join "\n"
  end

  def write_list file = nil
    output = generate_list
    case file
    when nil
      File.write "Найденные места.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

end
