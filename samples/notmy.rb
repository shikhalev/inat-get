User = INat::Entity::User
Place = INat::Entity::Place

user = User::by_login "shikhalev"
place = Place::by_slug "artinskiy-gorodskoy-okrug-osm-2023-sv-ru"

user_dataset = select user_id: user.id
place_dataset = select place_id: place.id

user_list = user_dataset.to_list
place_list = place_dataset.to_list

result_list = place_list - user_list

result_table = table do
  column "#", width: 3, align: :right, data: :line_no
  column "Таксон", data: :taxon
  column "К-во набл.", width: 6, align: :right, data: :count
end

result_rows = result_list.map { |ds| { taxon: ds.object, count: ds.count } }

result_table << result_rows

File.write "notmy.htm", result_table.to_html
