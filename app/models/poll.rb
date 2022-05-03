require_relative 'poll_choice'
require_relative 'common'
require_relative 'vote'
require_relative 'channel'
require_relative '../libs/embed'
require_relative '../libs/gp_logs'
require 'securerandom'


# A poll object
# A poll name is unique on a server
class Poll < ActiveRecord::Base
  belongs_to :server
  belongs_to :channel, optional: true

  has_many :votes
  has_many :voters, through: :votes

  has_many :add_other_games

  has_many :poll_choices
  has_many :games, -> {where('poll_choices.choice_type' => 'Game')}, through: :polls_choices

  extend Models::Common

  def show(discord_channel)

    buts = []
    # buts << Discordrb::Components::Button.new({label: :foo}, discord_channel.server.bot)
    # buts << Discordrb::Components::Button.new({'label' => :foo, 'style' => :primary}, nil)

    buttons_packs = []
    buttons_pack = []

    p self.poll_choices.includes(:choice).order(:emoji).to_a

    self.poll_choices.includes(:choice).order(:emoji).each do |pic|
      msg = "#{pic.choice.name}"
      key = pic.id

      if pic.choice.class.name == 'ServerChoice'
        next
      end

      buttons_pack << [msg, key, nil, :primary]

      if buttons_pack.length >= 5
        buttons_packs << buttons_pack
        buttons_pack = []
      end
    end

    buttons_pack << ['Autres', :foo, "\u{265F}", :secondary]
    buttons_packs << buttons_pack

    new_message = discord_channel.send_message(
      '', false, nil, nil, nil, nil,
      Discordrb::Components::View.new { |builder|

        add_game = "\u{2795}"
        keys = "\u{1F511}"
        away = "\u{1F4A4}"
        other = "\u{265F}"

        builder.row { |r|
            r.button(
              style:     :success,
              label:     'Présent avec les clefs',
              custom_id: 'palc',
              emoji: keys,
              disabled:  false
            )
            r.button(
              style:     :danger,
              label:     'Absent',
              custom_id: 'abs',
              emoji: away,
              disabled:  false
            )
            r.button(
              style:     :secondary,
              label:     'Ajouter un jeu',
              custom_id: 'add',
              emoji: add_game,
              disabled:  false
            )
          }

          buttons_packs.each do |b|
            builder.row { |r|
              b.each do |m|
                r.button(
                  style:     m[3],
                  label:     m[0],
                  custom_id: m[1],
                  emoji: m[2],
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

    emoji = 0
    server.server_choices.where(before: true).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end

    games_ids = poll_choices.where(choice_type: 'Game').pluck(:choice_id)
    games_ids += games.map{ |e| e.id }

    server.games.where(id: games_ids).order(:name).each do |g|
      emoji = set_models_choice(self, emoji, g)
    end

    server.server_choices.where(before: false).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end
  end

  private

  def set_models_choice(pi, emoji, choice)
    pig = PollChoice.where(poll_id: pi.id, emoji: emoji).first_or_initialize
    pig.choice = choice
    pig.save!
    emoji + 1
  end

  def set_choice_key(_klass, id)
    "#{_klass}_#{id}"
  end

end