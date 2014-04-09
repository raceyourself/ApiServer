class FacebookIdentity < Identity
  validates :uid, presence: true

  def generate_id
    uid
  end

  def update_from_facebook(data)
    self.uid = data['id']
    self.name = data['name']
    self.photo = data['picture']['data']['url'] if data['picture']
    self
  end
end
