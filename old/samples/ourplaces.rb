
require './findplaces'

report = FindPlaces::new place: INat::Entity::Place::by_id(139490)
report.write_list
