require_relative '../models/server'
require_relative '../models/channel'
require_relative '../models/poll_model'
require_relative '../models/poll_instances_choice'
require_relative 'poll_commands_extensions'
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

    extend PollCommandsExtensions

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
