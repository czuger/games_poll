class GpLogs

  @@logger = nil

  def self.debug(msg)
    get_logger.debug(msg)
  end

  def self.info(msg)
    get_logger.info(msg)
  end

  def self.error(msg)
    get_logger.info(msg)
  end

  private

  def self.get_logger
    @@logger ||= Logger.new('logs/general.log')
    @@logger
  end

end