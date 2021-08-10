class Embed

  def self.has_voters(voters_list)
    voters_list[self.choice_to_key(pic)] && !voters_list[self.choice_to_key(pic)].empty?
  end

  def self.choice_to_key(choice)
    choice.choice_type + choice.choice_id.to_s
  end

  def self.generate_embed_votes(embed, poll_instance)
    # embed.title = 'A quoi voulez vous jouer samedi.'
    title = poll_instance.poll_model.title

    games_list = []
    voters = {}
    poll_instance.votes.includes(:voter).order('voters.name').each do |votes|
      voters[self.choice_to_key(votes)] = []
      voters[self.choice_to_key(votes)] << votes.voter.name
    end

    poll_instance.poll_model.poll_models_choices.includes(:choice).order(:emoji).each do |pic|
      msg = "#{Vote.num_to_emoji(pic.emoji)} #{pic.choice.name}"

      if voters[self.choice_to_key(pic)] && !voters[self.choice_to_key(pic)].empty?
        msg += ' - ' + voters[self.choice_to_key(pic)].join(' - ')
      end

      games_list << msg
    end

    embed.add_field(name: title, value: games_list.join("\n"), inline: false)
    embed
  end

  def self.generate_embed_other_choice(embed, poll_model)
    games_list = []

    selected_games_ids = poll_model.poll_models_choices.pluck(:choice_id)
    poll_model.server.games.order(:name).where.not(id: selected_games_ids).each_with_index do |unselected_game, i|
      msg = "#{Vote.num_to_emoji(i)} #{unselected_game.name}"
      games_list << msg
    end

    embed.add_field(name: 'Other games', value: games_list.join("\n"), inline: false)
    embed
  end

end