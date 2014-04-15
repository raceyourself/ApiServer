class GplusIdentity < Identity
  validates :uid, presence: true

  def generate_id
    uid
  end

  def provider
    "google+"
  end

  def update_from_gplus(data)
    self.uid = data.id
    self.name = data.displayName
    self.photo = data.image.url
    self
  end
end
