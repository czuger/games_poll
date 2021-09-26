# frozen_string_literal: true

# This bot has various commands that show off CommandBot.

require 'discordrb'
require 'json'
require 'pp'
require 'uri'
require 'active_record'
require 'yaml'
require_relative 'models/server'
require_relative 'models/channel'
require_relative 'models/poll'
require_relative 'commands/common'
require_relative 'commands/games_commands'
require_relative 'commands/poll_commands'
require_relative 'reactions'

file = File.read('./config/bot.json')
data_hash = JSON.parse(file)

db_config = YAML.load_file( 'db/config.yml' )
ActiveRecord::Base.establish_connection(db_config['development'])
# Required to activate foreign keys on SQLite
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')
ActiveRecord::Base.logger = Logger.new STDOUT

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: data_hash['token'], prefix: Commands::Common::BOT_PREFIX, advanced_functionality: true

Reactions.start bot

Commands::GamesCommands.init_bot bot
Commands::PollCommands.init_bot bot

bot.run

# pp bot
bot.ready do |event|
  # pp event
end

# Thread.new do
#   bot.add_await!( Discordrb::Events::ReactionAddEvent) do |reaction_event|
#     # Since this code will run on every CROSS_MARK reaction, it might not
#     # be on our time message we sent earlier. We use `next` to skip the rest
#     # of the block unless it was our message that was reacted to.
#     # next true unless reaction_event.message.id == message.id
#
#     # Delete the matching message.
#     # message.delete
#
#     p reaction_event
#     p reaction_event.message.id
#     pp reaction_event
#     false
#   end
# end
#
# Thread.new do
#   bot.add_await!( Discordrb::Events::ReactionRemoveEvent) do |reaction_event|
#     # Since this code will run on every CROSS_MARK reaction, it might not
#     # be on our time message we sent earlier. We use `next` to skip the rest
#     # of the block unless it was our message that was reacted to.
#     # next true unless reaction_event.message.id == message.id
#
#     # Delete the matching message.
#     # message.delete
#
#     p reaction_event.message.id
#     false
#   end
# end

