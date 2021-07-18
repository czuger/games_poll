module Common

  def get_or_create(discord_id)
    object = self.where(discord_id: discord_id).first_or_initialize
    object.save!
    object
  end

end