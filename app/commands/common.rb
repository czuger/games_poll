module Commands
  class Common
    BOT_PREFIX = 'gp!'

    def self.help(event, commands)
      message = commands.map{ |e| "#{BOT_PREFIX}#{e[0]} - #{e[1]}"}.join("\n")
      event.channel.send_temporary_message(message, 30)
    end

    # Initialize the bot. First user to run the command is admin.
    def self.init(event)

      puts(Voter.all.count)

      if Voter.all.count == 0
        member = event.server.member(user_id)
        voter_name = member.nick
        voter_name ||= event.user.name

        voter = Voter.where(discord_id: event.user.id).first_or_initialize
        voter.name = voter_name
        voter.admin = true
        voter.save!

        event.channel.send_temporary_message('You are now admin', 30)
      end

    end
  end
end
