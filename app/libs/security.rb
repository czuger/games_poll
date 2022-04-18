require_relative '../libs/gp_logs'

class Security

  def self.is_admin?(event)
    admin_id = nil

    if File.exists?('config/bot.json')
      file = File.open('config/bot.json')
      config = JSON.parse file.read
      admins = config['admin_ids']
    end

    # p event.user.id
    GpLogs.debug "event.user.id = '#{event.user.id}'",
                 self.name, __method__

    # p admin_id
    GpLogs.debug "admins = #{admins}",
                 self.name, __method__

    GpLogs.debug "event.user.id in admin_ids : #{admins.include?(event.user.id.to_s)}",
                 self.name, __method__

    admins.include?(event.user.id.to_s)
  end

  def self.forbidden_message
    'You are not authorized to do that.'
  end

end