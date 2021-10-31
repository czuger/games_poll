require_relative '../models/server'
require_relative '../models/game'
require_relative 'common'
require_relative 'games/insert'
require_relative 'games/all'
require_relative '../libs/gp_logs'
require_relative '../libs/security'

module Commands
  class GamesCommands < Common

    COMMANDS = [
        [ 'ga', 'Add a new game (Admin only)' ],
        [ 'gu', 'Update a game name (Admin only)' ],
        [ 'gd', 'Delete a game (Admin only)' ],
        [ 'gf', 'Set a game favorite status (Admin only)' ],
        [ 'gl', 'List all games' ],
        [ 'gi', 'Set default games for server (Admin only)' ],
        [ 'gh', 'Show this message' ]
    ]

    def self.init_bot(bot)
      COMMANDS.map{|e| e[0]}.each do |command|
        bot.command command.to_sym do |event|
          self.send(command.to_s.gsub('-', '_'), event)
        end
      end

      GpLogs.info('GamesCommands initialized', self.name, __method__)
    end

    # Game add
    def self.ga(event)
      return Security.forbidden_message unless Security.is_admin? event
      Games::All.ga event.server.id, event.message.content
    end

    # Game update name
    def self.gu(event)
      return Security.forbidden_message unless Security.is_admin? event
      Games::All.find_and_exec(event.message.content) do |g, content|
        name = content.join(' ')
        g.name = name
        g.save!
      end
    end

    # Game del
    def self.gd(event)
      return Security.forbidden_message unless Security.is_admin? event
      Games::All.find_and_exec(event.message.content) do |g, _|
        g.destroy!
      end
    end

    # Set game favored status
    def self.gf(event)
      return Security.forbidden_message unless Security.is_admin? event
      Games::All.find_and_exec(event.message.content) do |g, _|
        g.favored = !g.favored
        g.save!
      end
    end

    # Game list
    def self.gl(event)
      return Games::All.gl event, event.server.id
    end

    # Set the default games for the server
    def self.gi(event)
      return Security.forbidden_message unless Security.is_admin? event
      Games::Insert.gi event.server.id
    end

    # Game help
    def self.gh(_)
      self.help(event, COMMANDS)
    end
  end
end
