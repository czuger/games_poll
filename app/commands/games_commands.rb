require_relative '../models/server'
require_relative '../models/game'
require_relative 'common'
require_relative 'games/insert'
require_relative 'games/all'

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
      Games::All.ga event.server.id
    end

    # Game update name
    def self.gu(event)
      Games::All.find_and_exec(event.message.content) do |g, content|
        name = content.join(' ')
        g.name = name
        g.save!
      end
    end

    # Game del
    def self.gd(event)
      Games::All.find_and_exec(event.message.content) do |g, _|
        g.destroy!
      end
    end

    # Set game favored status
    def self.gf(event)
      Games::All.find_and_exec(event.message.content) do |g, _|
        g.favored = !g.favored
        g.save!
      end
    end

    # Game list
    def self.gl(event)
      return Games::All.gl event.server.id
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
