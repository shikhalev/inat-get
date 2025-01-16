
require './finish'
require './userrep'

report = UserRep::new 'shikhalev', FINISH_DATE

report.write_history
