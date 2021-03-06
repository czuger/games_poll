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
require_relative 'commands/server_commands'
require_relative 'reactions'
require_relative 'libs/gp_logs'
require_relative 'commands/polls/restart'

file = File.read('./config/bot.json')
data_hash = JSON.parse(file)

db_config = YAML.load_file( 'db/config.yml' )
db_env = ENV['RAILS_ENV'] || 'development'
ActiveRecord::Base.establish_connection(db_config[db_env])

# Required to activate foreign keys on SQLite
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')
ActiveRecord::Base.logger = Logger.new 'log/db.log'

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new(
  token: data_hash['token'], prefix: Commands::Common::BOT_PREFIX, advanced_functionality: true,
  fancy_log: false, log_mode: :debug)

# bot.logger = Discordrb::Logger.new(fancy: true, streams: [Logger.new('log/discordrb.log')])
# Discordrb::LOGGER.streams = [Logger.new('log/discordrb.log')]

# Use views
# https://support.discord.com/hc/en-us/articles/360055709773-View-as-Role-FAQ

# Reactions.start bot
Reactions.start_reaction_to_buttons bot

Commands::GamesCommands.init_bot bot
Commands::PollCommands.init_bot bot
Commands::ServerCommands.init_bot bot

def refresh_polls_loop(bot)
  Thread.new do

    while true

      schedule_day = Time.now.wday
      scheduled_update_exclusion_duration = Time.now - 24*3600

      GpLogs.debug "Polling day : #{schedule_day}, time : #{scheduled_update_exclusion_duration}", 'Object', __method__

      Poll.where(schedule_day: schedule_day).where('updated_at < ?', scheduled_update_exclusion_duration).each do |poll|
      # Poll.where(schedule_day: schedule_day).each do |poll|

        GpLogs.debug "poll #{poll.id} will be printed due to schedule the #{Time.now}", 'Object', __method__
        GpLogs.debug "Bot token = #{bot.token}", 'Object', __method__

        if poll.channel
          GpLogs.debug "poll.channel = #{poll.channel}", 'Object', __method__
          GpLogs.debug "poll.channel.discord_id = #{poll.channel.discord_id}", 'Object', __method__

          channel = bot.channel(poll.channel.discord_id)
          GpLogs.debug "Channel name = #{channel.name}"

          Commands::Polls::Restart.pr(poll, channel)
        else
          GpLogs.error "Trying to restart a poll never started (#{poll.name})"
        end
      end

      sleep 3600
    end
  end
end

def save_permissions(bot)

  GpLogs.debug("Bot's servers", 'Object', __method__)

  GpLogs.debug(bot.servers.pretty_inspect, 'Object', __method__)

  first_server_id = bot.servers.keys.first

  GpLogs.debug(bot.servers[first_server_id].pretty_inspect, 'Object', __method__)

  bot_profile = bot.profile.on(bot.servers[first_server_id])

  permission_dict = {}
  flags = Discordrb::Permissions::FLAGS.map{ |e| e[1] }.sort

  flags.each do |flag|
    # GpLogs.debug("#{flag.to_s.ljust(20, ' ')} \t#{bot_profile.defined_permission?(flag)} \t#{bot_profile.permission?(flag)}",
    #              'Object', __method__)

    permission_dict[flag.to_s] = {
      defined_permission: bot_profile.defined_permission?(flag),
      permission: bot_profile.permission?(flag)
    }
  end

  File.write('/tmp/permissions.json', JSON.dump(permission_dict))
end

# pp bot
bot.ready do |event|
  # pp event
  GpLogs.info('Bot started', 'Object', __method__)
  # GpLogs.info(bot.pretty_inspect)

  save_permissions(bot)

  refresh_polls_loop(bot)
end

bot.run

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

