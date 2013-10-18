class TwitterIdentity < Identity
  field :uid, type: String
  field :name, type: String
  field :screen_name, type: String

  validates :uid, presence: true

  def generate_id
    uid
  end

  def update_from_twitter(data)
    self.uid = data.id
    self.name = data.name
    self.screen_name = data.screen_name
    self
  end
end
