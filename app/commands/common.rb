module Commands
  class Common
    BOT_PREFIX = 'gp!'

    def self.help(event, commands)
      message = commands.map{ |e| "#{BOT_PREFIX}#{e[0]} - #{e[1]}"}.join("\n")
      event.channel.send_temporary_message(message, 30)
    end

  end
end
