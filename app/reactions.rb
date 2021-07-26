require_relative 'models/poll_instance'
require_relative 'models/poll_instance'

class Reactions

  def self.start(bot)
    Thread.new do
      bot.add_await!( Discordrb::Events::ReactionAddEvent) do |reaction_event|
        up_vote reaction_event
        false
      end
    end
    Thread.new do
      bot.add_await!( Discordrb::Events::ReactionRemoveEvent) do |reaction_event|
        down_vote reaction_event
        false
      end
    end
  end

  def self.process_message(reaction_event)
    msg = PollInstance.where(discord_id: reaction_event.message.id).take
    if msg
      yield msg
    end
  end

  def self.up_vote(reaction_event)
    process_message(reaction_event) do |msg|
      emoji_number = reaction_event.emoji.name.ord - PollInstance::BASE_EMOJII
      p emoji_number
      # p msg
    end
  end

  def self.down_vote(reaction_event)
    process_message(reaction_event) do |msg|

    end
  end

end