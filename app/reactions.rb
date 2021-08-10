require_relative 'models/poll_instance'
require_relative 'models/poll_instance_choice'
require_relative 'models/voter'
require_relative 'models/vote'
require_relative 'models/add_other_game'

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
    Thread.new do
      bot.add_await!( Discordrb::Events::MessageEvent) do |reaction_event|
        f = AddOtherGame.where(discord_id: reaction_event.channel.id).first
        if f
          game = Game.where(id: f.choices[reaction_event.message.text.to_i]).first
          if game
            f.poll_instance.add_games([game])
          end
        end

        false
      end
    end
  end

  def self.process_message(reaction_event)
    # pp reaction_event.user
    # pp reaction_event.user_id
    ActiveRecord::Base.transaction do
      voter = Voter.where(discord_id: reaction_event.user.id).first_or_initialize
      voter.name = reaction_event.user.name
      voter.save!

      pi = PollInstance.where(discord_message_id: reaction_event.message.id).take
      # p pi
      if pi
        emoji_number = Vote.emoji_to_num(reaction_event.emoji.name)
        # puts "Emoji reaction : #{emoji_number}"

        poll_choice = pi.poll_instance_choices.where(emoji: emoji_number).take
        # p game_id

        if poll_choice
          yield pi, voter, poll_choice, reaction_event.user

          self.update_voters(reaction_event, pi)
        else
          p "PollInstancesGame #{pi.id} not found !"
        end
      else
        p "PollInstance #{reaction_event.message.id} not found !"
      end
    end
  end

  def self.update_voters(reaction_event, pi)
    new_embed = Discordrb::Webhooks::Embed.new
    new_embed = Embed.generate_embed_votes(new_embed, pi)
    reaction_event.message.edit(nil, new_embed=new_embed)
  end

  def self.up_vote(reaction_event)
    process_message(reaction_event) do |pi, voter, poll_choice, sender|
      if poll_choice.is_others_games_button?
        # pp poll_choice
        channel = sender.pm
        result = channel.send_embed do |embed|
          embed = Embed.generate_embed_other_choice(channel, embed, pi)
        end
      else
        vote = Vote.where(poll_instance_id: pi.id, voter_id: voter.id,
                          choice_id: poll_choice.choice_id,
                          choice_type: poll_choice.choice_type).first_or_initialize
        vote.save!
      end
    end
  end

  def self.down_vote(reaction_event)
    process_message(reaction_event) do |pi, voter, poll_choice, sender|
      Vote.where(poll_instance_id: pi.id, voter_id: voter.id,
                 choice_id: poll_choice.choice_id, choice_type: poll_choice.choice_type).delete_all
    end
  end

end