require_relative '../models/server'
require_relative '../models/game'
require_relative 'common'
require_relative 'games/insert'
require_relative 'games/all'
require_relative '../libs/gp_logs'
require_relative '../libs/security'
require 'yaml'

module Commands
  class ServerCommands < Common

    COMMANDS = [
        [ 'init_server', 'Initialize the bot on a new server.' ]
    ]

    def self.init_bot(bot)
      COMMANDS.map{|e| e[0]}.each do |command|
        bot.command command.to_sym do |event|
          self.send(command.to_s.gsub('-', '_'), event)
        end
      end

      GpLogs.info('GamesCommands initialized', self.name, __method__)
    end

    # Initialize the bot. First user to run the command is admin.
    def self.init_server(event)

      ActiveRecord::Base.transaction do
        # Set the first user that initialize the bot as admin.
        if Voter.all.count == 0
          member = event.server.member(event.user.id)
          voter_name = member.nick
          voter_name ||= event.user.name

          #TODO : Voters -> need to be linked to a server.
          voter = Voter.where(discord_id: event.user.id).first_or_initialize
          voter.name = voter_name
          voter.admin = true
          voter.save!

          event.channel.send_temporary_message('You are now admin', 30)
        else
          event.channel.send_temporary_message('Bootstrap admin already set', 30)
        end

        if File.exists?('data/server_init.yaml')
          init_dict = YAML.load_file 'data/server_init.yaml'

          p 'init dict'
          p init_dict

          server = Server.get_or_create(event.server.id)

          init_dict[:games].each do |g|
            db_game = Game.where(server_id: server.id, name: g[:name]).first_or_initialize
            db_game.favored = g[:favored]
            db_game.save!
          end

          init_dict[:server_choice].each do |sc|
            db_sc = ServerChoice.where(server_id: server.id, name: sc[:name]).first_or_initialize
            db_sc.first_row = sc[:first_row]
            db_sc.emoji = sc[:emoji]
            db_sc.button_style = sc[:button_style]
            db_sc.run_command = sc[:run_command]
            db_sc.save!
          end

        end

        event.channel.send_temporary_message('Server initialization finished', 30)
      end
    end

    # Game help
    def self.gh(_)
      self.help(event, COMMANDS)
    end
  end
end
