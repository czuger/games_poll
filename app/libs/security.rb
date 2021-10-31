require_relative '../libs/gp_logs'

class Security

  def self.is_admin?(event)
    admin_id = nil

    if File.exists?('config/bot.json')
      file = File.open('config/bot.json')
      admin = JSON.parse file.read
      admin_id = admin['admin_id']
    end

    # p event.user.id
    GpLogs.debug "event.user.id = '#{event.user.id}'",
                 self.name, __method__

    # p admin_id
    GpLogs.debug "admin_id = '#{admin_id}'",
                 self.name, __method__

    GpLogs.debug "event.user.id == admin_id : #{event.user.id == admin_id.to_i}",
                 self.name, __method__

    event.user.id == admin_id.to_i
  end

  def self.forbidden_message
    'You are not authorized to do that.'
  end

end