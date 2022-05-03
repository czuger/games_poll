require 'yaml'

init_dict = {games: [], server_choice: []}

File.open('../data/all.txt').readlines.each do |title|
  init_dict[:games] << {name: title.strip, favored: false}
end

File.open('../data/favored.txt').readlines.each do |title|
  init_dict[:games] << {name: title.strip, favored: true}
end

init_dict[:server_choice] <<
  {name: 'Present avec les clefs', button_style: :success, emoji: '\u{1F511}', first_row: true}

init_dict[:server_choice] <<
  {name: 'Absent', button_style: :danger, emoji: '\u{1F4A4}', first_row: true}

init_dict[:server_choice] <<
  {name: 'Ajouter un jeu', button_style: :secondary, emoji: '\u{2795}', run_command: :add_game, first_row: true}

init_dict[:server_choice] <<
  {name: 'Autres', button_style: :secondary, emoji: '\u{265F}', first_row: false}

File.open('../data/server_init.yaml', 'w') do |f|
  f.write(init_dict.to_yaml)
end