module PollCommandsExtensions

  # Poll add
  def pa(event)
    content = event.message.content.split
    content.shift
    name = content.shift
    title = content.join(' ')

    discord_channel_id = event.channel.id
    discord_server_id = event.channel.server.id

    server = Server.get_or_create(discord_server_id)
    # channel = Channel.get_or_create(discord_channel_id, server.id)

    ActiveRecord::Base.transaction do
      pm = PollModel.where(server_id: server.id, name: name).first_or_initialize
      pm.title = title
      pm.save!

      pm.add_games(server.games.where(favored: true))
      # pi.show event
      # The id of the message is changed during show. Indeed, we need the id of the message
      # we created, not the id of the command that required poll creation.
      pm.save!
    end
    # end
    'Poll added'
  end
end