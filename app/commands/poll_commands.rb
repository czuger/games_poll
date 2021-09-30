require_relative '../models/server'
require_relative '../models/channel'
require_relative '../models/poll_model'
require_relative '../models/poll_choice'
require_relative '../models/poll'
require_relative 'polls/add'
require_relative 'common'
require_relative 'polls/add'
require_relative '../libs/gp_logs'
require 'pp'

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

    def self.init_bot(bot)
      COMMANDS.map{|e| e[0]}.each do |command|
        bot.command command.to_sym do |event|
          self.send(command.to_s.gsub('-', '_'), event)
        end
      end

      GpLogs.info('PollCommands initialized')
    end

    def self.find_and_exec(event)
      content = event.message.content.split
      content.shift
      poll_name_or_id = content.shift

      server = Server.get_or_create(event.server.id)

      ActiveRecord::Base.transaction do
        # Find raise an error if not found
        p = server.polls.where(id: poll_name_or_id).first
        p = p || server.polls.where(name: poll_name_or_id).first

        if p
          result = yield p, content
          result ||= 'Done'
          event.channel.send_temporary_message(result, 30)
        else
          event.channel.send_temporary_message('Poll not found', 30)
        end
      end
    end

    # Poll schedule
    def self.ps(event)
      content = event.message.content.split
      content.shift
      poll_name = content.shift

      GpLogs.debug "In PollCommands.ps : content = #{content}"

      ActiveRecord::Base.transaction do
        server = Server.get_or_create(event.server.id)
        channel = server.get_or_create_channel(event.channel.id)

        p = server.polls.where(name: poll_name).first

        if p
          p.schedule_day = content.first.to_i
          p.channel = channel
          p.save!
          "Poll #{p.name} schedule updated to #{p.schedule_day}"
        else
          "Poll #{poll_name} does not exists"
        end
      end
    end


    # TODO : After adding a new game, need to show the poll again
    # Also need to set votes for voters.
    # When resetting the poll instance (in case of reset or consequence of schedule)
    # Add a table called votes_history and move old votes into this table (same type as votes)
    # Display a poll
    def self.pd(event)
      server = Server.get_or_create(event.server.id)
      poll = server.get_poll(event.message.content)
      poll.show(event.channel)
      nil
    end

    # Poll list
    def self.pl(event)
      s = Server.get_or_create event.server.id

      polls_list = s.polls.order(:name).map do |pm|
        # schedules = pm.poll_schedules.map{ |e| e.day }.join(', ')
        "#{pm.id} - #{pm.name} - #{pm.schedule_day}\n"
      end

      # GpLogs.debug polls_list.pretty_inspect

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

        polls_to_remove = pi.poll_choices.order('created_at').to_a
        polls_to_remove.shift(5)

        PollChoice.delete(polls_to_remove.map(&:id))
        'Polls removed : #{polls_to_remove.map(&:id)}'
      end
    end

    # Create a new poll
    def self.pa(event)
      Polls::Add.pa(
        event.channel.server.id, event.message.content)
    end

    # Poll help
    def self.ph(event)
      self.help(event, COMMANDS)
    end
  end
end
