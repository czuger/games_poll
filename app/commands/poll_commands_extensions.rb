module PollCommandsExtensions

  # Force create instance and showservers
  def pf(event)
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

      emoji = 0
      server.orga_choices.where(before: true).order(:name).each do |orga|
        emoji = set_instances_choice(pi, emoji, orga)
      end

      server.games.order(:name).each do |g|
        emoji = set_instances_choice(pi, emoji, g)
      end

      server.orga_choices.where(before: false).order(:name).each do |orga|
        emoji = set_instances_choice(pi, emoji, orga)
      end

      pi.show event
      # The id of the message is changed during show. Indeed, we need the id of the message
      # we created, not the id of the command that required poll creation.
      pi.save!
    end
    # end
    nil
  end

  private

  def set_instances_choice(pi, emoji, choice)
    pig = PollInstancesChoice.where(poll_instance_id: pi.id, emoji: emoji).first_or_initialize
    pig.choice = choice
    pig.save!
    emoji + 1
  end


end