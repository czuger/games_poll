require_relative 'poll_choice'
require_relative 'common'
require_relative 'vote'
require_relative 'channel'
require_relative '../libs/embed'
require_relative '../libs/gp_logs'
require 'securerandom'
require 'active_support'


# A poll object
# A poll name is unique on a server
class Poll < ActiveRecord::Base
  belongs_to :server
  belongs_to :channel, optional: true

  has_many :votes
  has_many :voters, through: :votes

  has_many :add_other_games

  has_many :poll_choices
  has_many :games, -> {where('poll_choices.choice_type' => 'Game').order('games.name')}, through: :polls_choices

  has_many :first_rows, -> {
    where('poll_choices.choice_type' => 'ServerChoice',
          'poll_choices.first_row' => true).order('poll_choices.id') },
           class_name: 'PollChoice'

  has_many :games_choices, -> {
    where('poll_choices.choice_type' => 'Game').order('poll_choices.name') },
           class_name: 'PollChoice'

  has_many :others, -> {
    where('poll_choices.choice_type' => 'ServerChoice',
          'poll_choices.first_row' => false).order('poll_choices.id') },
           class_name: 'PollChoice'

  #
  # has_many :others, -> {
  #   where('poll_choices.choice_type' => 'ServerChoice',
  #         'server_choices.first_row' => False).order('server_choices.id') },
  #          class_name: ServerChoice, through: :polls_choices


  extend Models::Common

  def show(discord_channel)

    emoji = '\u00a9'

    new_message = discord_channel.send_message(
      '', false, nil, nil, nil, nil,
      Discordrb::Components::View.new { |builder|

        builder.row { |r|
          self.first_rows.each do |fr|
            r.button(
              style:     fr.button_style.to_sym,
              label:     fr.name,
              custom_id: fr.id,
              emoji: fr.emoji,
              disabled:  false
            )
          end
        }

        games = self.games_choices + self.others

        games.in_groups_of(5, false).each do |_row|
          builder.row { |r|
            _row.each do |g|
              r.button(
                style:     :primary,
                label:     g.name,
                custom_id: g.id,
                emoji: g.emoji,
                disabled:  false
              )
            end
          }
        end
      }.to_a
    )


    # embed = Embed.generate_embed_votes(embed, self)

    # new_message = discord_channel.send_embed(:foo, embed: embed, components: buts)

    # self.poll_choices.order(:emoji).each do |pic|
    #     sleep(0.1)
    #     new_message.create_reaction(Vote.num_to_emoji(pic.emoji))
    # end

    # As we created a new message, we need to relink the poll to that new message id.

    ActiveRecord::Base.transaction do
      GpLogs.debug "In Poll.show : discord_channel.server = #{discord_channel.server}", self.name, __method__

      server = Server.get_or_create(discord_channel.server.id)
      channel = Channel.get_or_create(discord_channel.id, server.id)

      self.discord_message_id = new_message.id
      self.channel = channel
      self.save!
    end
  end

  def add_games(games)
    server = self.server

    server.server_choices.order(:id).each do |sc|
      set_models_choice(self, sc)
    end

    games_ids = poll_choices.where(choice_type: 'Game').pluck(:choice_id)
    games_ids += games.map{ |e| e.id }

    server.games.where(id: games_ids).order(:id).each do |g|
      set_models_choice(self, g)
    end
  end

  private

  def set_models_choice(pi, data)
    pig = PollChoice.where(poll_id: pi.id, choice_id: data.id, choice_type: data.class.to_s).first_or_initialize

    pig.first_row = data.first_row
    pig.emoji = data.emoji
    pig.button_style = data.button_style
    pig.run_command = data.run_command
    pig.name = data.name
    pig.save!
  end

  def set_choice_key(_klass, id)
    "_klass_#{id}"
  end

end