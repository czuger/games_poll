require_relative '../models/add_other_game'
require_relative 'gp_logs'

class Embed

  def self.has_voters(voters_list)
    voters_list[self.choice_to_key(pic)] && !voters_list[self.choice_to_key(pic)].empty?
  end

  def self.choice_to_key(choice)
    choice.choice_type + choice.choice_id.to_s
  end

  def self.generate_embed_votes(embed, poll)
    # embed.title = 'A quoi voulez vous jouer samedi.'
    title = poll.title

    games_list = []
    voters = {}

    poll.votes.includes(:voter).order('voters.name').each do |votes|
      voters[self.choice_to_key(votes)] ||= []
      voters[self.choice_to_key(votes)] << votes.voter.name
    end

    GpLogs.debug(voters, self.name, __method__)

    poll.poll_choices.includes(:choice).order(:emoji).each do |pic|
      msg = "#{Vote.num_to_emoji(pic.emoji)} #{pic.choice.name}"

      if voters[self.choice_to_key(pic)] && !voters[self.choice_to_key(pic)].empty?
        msg += ' : ' + voters[self.choice_to_key(pic)].join(', ')
      end

      games_list << msg
    end

    GpLogs.debug "Games list #{games_list}", self.name, __method__

    embed.add_field(name: title, value: games_list.join("\n"), inline: false)
    embed
  end

  def self.generate_embed_other_choice(channel, embed, poll)
    games_list = []
    games_codes = {}

    pm = poll
    selected_games_ids = poll.poll_choices.pluck(:choice_id)
    pm.server.games.order(:name).where.not(id: selected_games_ids).each_with_index do |unselected_game, i|
      games_codes[i+1] = unselected_game.id

      msg = "#{i+1} - #{unselected_game.name}"
      games_list << msg
    end

    aog = AddOtherGame.where(discord_id: channel.id).first_or_initialize
    # p aog
    aog.poll = poll
    aog.choices = games_codes
    aog.save!

    embed.add_field(name: 'Other games', value: games_list.join("\n"), inline: false)
    embed
  end

end