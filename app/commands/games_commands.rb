require_relative '../models/server'
require_relative '../models/game'
require_relative 'common'
require_relative './games/insert'

module Commands
  class GamesCommands < Common

    COMMANDS = [
        [ 'ga', 'Add a new game' ],
        [ 'gu', 'Update a game name' ],
        [ 'gd', 'Delete a game' ],
        [ 'gf', 'Set a game favorite status' ],
        [ 'gl', 'List all games' ],
        [ 'gi', 'Set default games for server' ],
        [ 'gh', 'Show this message' ]
    ]

    def self.init_bot(bot)
      COMMANDS.map{|e| e[0]}.each do |command|
        bot.command command.to_sym do |event|
          self.send(command.to_s.gsub('-', '_'), event)
        end
      end
    end

    # Game add
    def self.ga(event)
      s = Server.get_or_create event.server.id
      content = event.message.content.split

      content.shift
      name = content.join(' ')

      g = Game.where(server_id: s.id, name: name).first_or_initialize
      g.name = name
      g.save!
    end

    # Game update
    def self.gu(event)
      self.find_and_exec(event) do |g, content|
        name = content.join(' ')
        g.name = name
        g.save!
      end
    end

    # Game del
    def self.gd(event)
      self.find_and_exec(event) do |g, _|
        g.destroy!
      end
    end

    # Set game favored status
    def self.gf(event)
      self.find_and_exec(event) do |g, _|
        g.favored = !g.favored
        g.save!
      end
    end

    # Game list
    def self.gl(event)
      s = Server.get_or_create event.server.id

      game_list_message = s.games.order(:name).map{ |e| "#{e.id} - #{e.name} #{('+' if e.favored)}\n" }.join
      p game_list_message
      event.channel.send_temporary_message(game_list_message, 30)
    end

    # Set the default games for the server
    def self.gi(event)
      Games::Insert.gi event.server.id
    end

    # Game help
    def self.gh(_)
      self.help(event, COMMANDS)
    end
  end
end
