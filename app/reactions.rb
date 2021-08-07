require_relative 'models/poll_instance'
require_relative 'models/poll_instances_choice'
require_relative 'models/voter'
require_relative 'models/vote'

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
    # pp reaction_event.user
    # pp reaction_event.user_id
    ActiveRecord::Base.transaction do
      voter = Voter.where(discord_id: reaction_event.user.id).first_or_initialize
      voter.name = reaction_event.user.name
      voter.save!

      pi = PollInstance.where(discord_id: reaction_event.message.id).take
      # p pi
      if pi
        emoji_number = Vote.emoji_to_num(reaction_event.emoji.name)
        puts "Emoji reaction : #{emoji_number}"

        poll_choice = PollInstancesChoice.where(poll_instance_id: pi.id, emoji: emoji_number).take
        # p game_id

        if poll_choice
          yield pi, voter, poll_choice

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
    new_embed = PollInstance.generate_embed(new_embed, pi)
    reaction_event.message.edit(nil, new_embed=new_embed)
  end

  def self.up_vote(reaction_event)
    process_message(reaction_event) do |pi, voter, poll_choice|

      vote = Vote.where(poll_instance_id: pi.id, voter_id: voter.id,
                        choice_id: poll_choice.choice_id, choice_type: poll_choice.choice_type).first_or_initialize
      vote.save!
    end
  end

  def self.down_vote(reaction_event)
    process_message(reaction_event) do |pi, voter, poll_choice|
      Vote.where(poll_instance_id: pi.id, voter_id: voter.id,
                 choice_id: poll_choice.choice_id, choice_type: poll_choice.choice_type).delete_all
    end
  end

end