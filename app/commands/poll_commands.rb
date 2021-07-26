require_relative '../models/server'
require_relative '../models/channel'
require_relative '../models/poll_model'

require_relative 'common'

module Commands
  class PollCommands < Common
    COMMANDS = [
        [ 'pa', 'Create a new poll model' ],
        [ 'ps', 'Schedule a poll model' ],
        [ 'pf', 'Force create instance and show' ],
        [ 'pl', 'List poll models' ],
        [ 'ph', 'Show this message' ]
    ]

    def self.init_bot(bot)
      COMMANDS.map{|e| e[0]}.each do |command|
        bot.command command.to_sym do |event|
          self.send(command.to_s.gsub('-', '_'), event)
        end
      end
    end

    def self.find_and_exec(event)
      content = event.message.content.split

      content.shift
      poll_id = content.shift
      # Find raise an error if not found
      p = PollModel.find_by(id: poll_id)

      if p
        yield p, content
        event.channel.send_temporary_message('Done', 30)
      else
        event.channel.send_temporary_message('Poll not found', 30)
      end
    end

    def self.show_poll(poll, event)
      result = event.channel.send_embed do |embed|
        # p embed

        embed.title = 'A quoi voulez vous jouer samedi.'
        # embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://www.ruby-lang.org/images/header-ruby-logo.png')
        # embed.description = "
      # :black_small_square: **a**: foo\n
      # :black_small_square: **b**: bar\n
      #   "

        poll.games.order(:name).each do |g|
          embed.add_field(name: g.name, value: 'foo', inline: true)
        end
      end

      poll.games.order(:name).each_with_index do |g, i|

        emojii_code = 127462 + i
        emoji = [emojii_code].pack('U*')

        sleep(0.1)

        result.create_reaction emoji
      end
    end


    # Poll add
    def self.pa(event)
      s = Server.get_or_create event.server.id

      content = event.message.content.split
      content.shift
      name = content.join(' ')

      g = PollModel.where(server_id: s.id, name: name).first_or_initialize
      g.name = name
      g.save!
    end

    # Poll schedule
    def self.ps(event)
      self.find_and_exec(event) do |p, content|
        day = content.shift

        ps = PollSchedule.where(poll_model_id: p.id, day: day).first_or_initialize
        ps.day = day
        ps.save!
      end
    end

    # Force create instance and showservers
    def self.pf(event)
        params = event.message.content.split
        params.shift
        # poll_id = params.shift

        discord_message_id = event.message.id
        discord_channel_id = event.channel.id
        discord_server_id = event.channel.server.id

        server = Server.get_or_create(discord_server_id)
        channel = Channel.get_or_create(discord_channel_id, server.id)
        # poll_model = server.poll_models.find(poll_id)

        ActiveRecord::Base.transaction do
          pi = PollInstance.where(discord_id: discord_message_id).first_or_initialize
          pi.channel_id = channel.id
          pi.save!

          server.games.each do |g|
            pi.games << g
          end

          self.show_poll pi, event
        end
      # end
      nil
    end

    # Poll list
    def self.pl(event)
      s = Server.get_or_create event.server.id

      polls_list = s.poll_models.order(:name).map do |pm|
        schedules = pm.poll_schedules.map{ |e| e.day }.join(', ')
        "#{pm.id} - #{pm.name} - #{schedules}\n"
      end

      if polls_list.empty?
        'No polls'
      else
        event.channel.send_temporary_message(polls_list.join, 30)
      end
    end

    # Poll help
    def self.ph(event)
      self.help(event, COMMANDS)
    end
  end
end
