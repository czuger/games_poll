# frozen_string_literal: true

# This bot has various commands that show off CommandBot.

require 'discordrb'
require 'json'
require 'pp'
require 'uri'

file = File.read('./config/bot.json')
data_hash = JSON.parse(file)

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: data_hash['token'], prefix: '!', advanced_functionality: true

# pp bot
bot.ready do |event|
  # pp event
end

Thread.new do
  bot.add_await!( Discordrb::Events::ReactionAddEvent) do |reaction_event|
    # Since this code will run on every CROSS_MARK reaction, it might not
    # be on our time message we sent earlier. We use `next` to skip the rest
    # of the block unless it was our message that was reacted to.
    # next true unless reaction_event.message.id == message.id

    # Delete the matching message.
    # message.delete

    p reaction_event.message.id
    false
  end
end

Thread.new do
  bot.add_await!( Discordrb::Events::ReactionRemoveEvent) do |reaction_event|
    # Since this code will run on every CROSS_MARK reaction, it might not
    # be on our time message we sent earlier. We use `next` to skip the rest
    # of the block unless it was our message that was reacted to.
    # next true unless reaction_event.message.id == message.id

    # Delete the matching message.
    # message.delete

    p reaction_event.message.id
    false
  end
end

bot.command :poll do |event|
  # Commands send whatever is returned from the block to the channel. This allows for compact commands like this,
  # but you have to be aware of this so you don't accidentally return something you didn't intend to.
  # To prevent the return value to be sent to the channel, you can just return `nil`.

  p event.channel
  p event.server

  result = event.channel.send_embed do |embed|
    # p embed

    embed.title = 'The Ruby logo'
    # embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://www.ruby-lang.org/images/header-ruby-logo.png')
    embed.description = "
      :black_small_square: **a**: foo\n
      :black_small_square: **b**: bar\n
    "

    embed.add_field(name: 'Server Name', value: 'foo', inline: true)
  end

  127462.upto(127462+3).each do |i|
    sleep(0.1)
    emoji = [i].pack('U*')
    p emoji
    result.create_reaction emoji
  end

end

bot.run