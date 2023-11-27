
project = Entity::Project::by_slug 'ptitsy-artinskogo-rayona-zima'
finish = Date::parse '2023-03-01'

main_ds = select project: project, d2: finish
hist_ls = main_ds.to_list Listers::WINTER

history = history_table hist_ls

File.write 'Птицы (зима) - История.htm', history.to_html
