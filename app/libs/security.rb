require_relative '../libs/gp_logs'

class Security

  def self.is_admin?(event)
    # p event.user.id
    GpLogs.debug "event.user.id = '#{event.user.id}'",
                 self.name, __method__

    voter = Voter.find_by(discord_id: event.user.id)

    # p admin_id
    GpLogs.debug "voter = #{voter}",
                 self.name, __method__

    voter.admin?
  end

  def self.forbidden_message
    'You are not authorized to do that.'
  end

end