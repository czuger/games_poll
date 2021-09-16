require_relative '../models/server'
require_relative '../models/channel'
require_relative '../models/poll_model'
require_relative '../models/poll_instance_choice'
require_relative '../models/poll_instance'
require_relative 'poll_commands_extensions'
require_relative 'common'

module Commands
  class PollCommands < Common
    COMMANDS = [
        [ 'pa', 'Create a new poll' ],
        [ 'ps', 'Schedule a poll' ],
        [ 'pd', 'Display a poll' ],
        [ 'pl', 'List poll' ],
        [ 'pc', 'Clean polls' ],
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
      poll_name_or_id = content.shift

      ActiveRecord::Base.transaction do
        # Find raise an error if not found
        p = PollModel.where(id: poll_name_or_id).
          or(PollModel.where(name: poll_name_or_id)).first

        if p
          yield p, content
          event.channel.send_temporary_message('Done', 30)
        else
          event.channel.send_temporary_message('Poll not found', 30)
        end
      end

    end

    # Poll schedule
    # def self.ps(event)
    #   self.find_and_exec(event) do |p, content|
    #     day = content.shift
    #
    #     ps = PollSchedule.where(poll_model_id: p.id, day: day).first_or_initialize
    #     ps.day = day
    #     ps.save!
    #   end
    # end


    # TODO : After adding a new game, need to show the poll again
    # Also need to set votes for voters.
    # When resetting the poll instance (in case of reset or consequence of schedule)
    # Add a table called votes_history and move old votes into this table (same type as votes)
    # Display a poll
    def self.pd(event)
      self.find_and_exec(event) do |pm, _|
        pi = pm.get_or_create_instance(event)
        pi.show(event.channel)
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

    # Clean poll (remove old games - in the future : unvoted games)
    def self.pc(event)
      self.find_and_exec(event) do |pm, _|
        pi = pm.get_or_create_instance(event)

        polls_to_remove = pi.poll_instance_choices.order('created_at').to_a
        polls_to_remove.shift(5)

        PollInstanceChoice.delete(polls_to_remove.map(&:id))
        'Polls removed : #{polls_to_remove.map(&:id)}'
      end
    end

    # Poll help
    def self.ph(event)
      self.help(event, COMMANDS)
    end
  end
end
