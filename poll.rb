# frozen_string_literal: true

# This bot has various commands that show off CommandBot.

require 'discordrb'
require 'json'
require 'pp'

file = File.read('./config.json')
data_hash = JSON.parse(file)

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: data_hash['token'], prefix: '!', advanced_functionality: true

pp bot

bot.command :poll do |event|
  # Commands send whatever is returned from the block to the channel. This allows for compact commands like this,
  # but you have to be aware of this so you don't accidentally return something you didn't intend to.
  # To prevent the return value to be sent to the channel, you can just return `nil`.
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

  p result
  # result.await!(timeout: 1) do |guess_event|
  #   p guess_event
  #   guess_event.create_reaction('foo')
  # end

  m = event.channel.load_message(result.id)
  p m

  m.create_reaction(':who:')

  p 'After'

end

bot.run