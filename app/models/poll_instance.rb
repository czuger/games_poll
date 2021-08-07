require_relative 'common'

class PollInstance < ActiveRecord::Base
  has_many :votes
  has_many :voters, through: :votes

  has_many :poll_instances_choices
  # has_many :choices, -> { order 'poll_instances_games.emoji' }, through: :poll_instances_choices

  extend Models::Common

  def self.choice_to_key(choice)
    choice.choice_type + choice.choice_id.to_s
  end

  def self.generate_embed(embed, poll_instance)
    # embed.title = 'A quoi voulez vous jouer samedi.'
    title = 'A quoi voullez vous jouer samedi ?'

    games_list = []

    voters = {}
    poll_instance.votes.includes(:voter).order('voters.name').each do |votes|
      voters[self.choice_to_key(votes)] = []
      voters[self.choice_to_key(votes)] << votes.voter.name
    end

    # poll_instance.poll_instances_choices.order(:emoji).each do |pic|
    #   msg = "#{PollInstance.num_to_emoji(pic.emoji)} : #{pic.choice.name}"
    #
    #   voters = Vote.where(poll_instance_id: pic.id, choice_id: pic.choice_id, choice_type: pic.choice_type).
    #     includes(:voter).map{ |e| e.voters.name }
    #   unless voters.empty?
    #     msg += ' - ' + voters.join(' - ')
    #   end
    #
    #   games_list << msg
    # end

    poll_instance.poll_instances_choices.includes(:choice).order(:emoji).each do |pic|
        msg = "#{Vote.num_to_emoji(pic.emoji)} : #{pic.choice.name}"

        if voters[self.choice_to_key(pic)] && !voters[self.choice_to_key(pic)].empty?
          msg += ' - ' + voters[self.choice_to_key(pic)].join(' - ')
        end

        games_list << msg
    end

    embed.add_field(name: title, value: games_list.join("\n"), inline: false)
    embed
  end

  def show(event)
    result = event.channel.send_embed do |embed|
      embed = PollInstance.generate_embed(embed, self)
    end

    poll_instances_choices.order(:emoji).each do |pic|
        sleep(0.1)
        result.create_reaction(Vote.num_to_emoji(pic.emoji))
    end

    # games.order(:name).each_with_index do |g, i|
    #   sleep(0.1)
    #   result.create_reaction(PollInstance.num_to_emoji(i))
    # end

    self.discord_id = result.id
  end

end