# frozen_string_literal: true

module AppInfo

  AUTHOR = 'Ivan Shikhalev'
  EMAIL = 'shkikhalev@gmail.com'

  VERSION = '0.8.0.12'
  HOMEPAGE = 'https://github.com/shikhalev/inat-get'
  SOURCE_URL = 'https://github.com/shikhalev/inat-get'

  EXE = File.basename $0
  NAME = File.basename $0, '.rb'

  USAGE = "\e[1mUsage $\e[0m #{EXE} [options] ‹task[, ...]›"
  ABOUT = "\e[1mINat::Get v#{VERSION}\e[0m — A toolset for fetching and processing data from \e[4miNaturalist.org\e[0m.\n" +
          "\n" +
          "\e[1mSource:\e[0m \e[4m#{HOMEPAGE}\e[0m\n" +
          "\e[1mAuthor:\e[0m #{AUTHOR} ‹\e[4m#{EMAIL}\e[0m›"

end
