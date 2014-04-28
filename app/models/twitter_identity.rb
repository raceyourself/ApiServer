class TwitterIdentity < Identity
  validates :uid, presence: true

  def generate_id
    uid
  end

  def update_from_twitter(data)
    self.uid = data.id.to_s
    self.name = data.name
    self.screen_name = data.screen_name
    self.photo = data.profile_image_url
    self
  end
end
