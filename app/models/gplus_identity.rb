class GplusIdentity < Identity
  field :uid, type: String
  field :name, type: String
  field :photo, type: String

  validates :uid, presence: true

  def generate_id
    uid
  end

  def update_from_gplus(data)
    self.uid = data.id
    self.name = data.displayName
    self.photo = data.image.url
    self
  end
end
