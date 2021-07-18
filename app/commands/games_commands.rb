require_relative '../models/server'
require_relative '../models/game'

class GamesCommands

  def self.game_add(event)
    s = Server.get_or_create event.server.id
    content = event.message.content.split

    content.shift
    name = content.join(' ')

    g = Game.where(server_id: s.id, name: name).first_or_initialize
    g.name = name
    g.save!
  end

  def self.game_favored(event)
    s = Server.get_or_create event.server.id
    content = event.message.content.split

    game_id = content[1]
    g = Game.find(game_id)

    if g
      g.favored = !g.favored
      g.save!
      event.channel.send_temporary_message('Done', 30)
    else
      event.channel.send_temporary_message('Game not found', 30)
    end
  end

  def self.game_list(event)
    s = Server.get_or_create event.server.id

    game_list_message = s.games.map{ |e| "#{e.id} - #{e.name} #{('+' if e.favored)}\n" }.join
    p game_list_message
    event.channel.send_temporary_message(game_list_message, 30)
  end


end