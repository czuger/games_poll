require 'yaml'

tmp_games = {}
init_dict = {games: [], server_choice: []}

File.open('all.txt').readlines.each do |title|
  tmp_games[title.strip] = {name: title.strip, favored: false}
end

File.open('favored.txt').readlines.each do |title|
  tmp_games[title.strip] = {name: title.strip, favored: true}
end

for v in tmp_games.values
  init_dict[:games] << v
end

init_dict[:server_choice] <<
  {name: 'Present avec les clefs', button_style: :success, emoji: '🔑', first_row: true}

init_dict[:server_choice] <<
  {name: 'Absent', button_style: :danger, emoji: '💤', first_row: true}

init_dict[:server_choice] <<
  {name: 'Ajouter un jeu', button_style: :secondary, emoji: '➕', run_command: :add_game, first_row: true}

init_dict[:server_choice] <<
  {name: 'Autres', button_style: :secondary, emoji: '♟', first_row: false}

File.open('../../config/server_init.yaml', 'w') do |f|
  f.write(init_dict.to_yaml)
end