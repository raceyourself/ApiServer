class EmailIdentity < Identity
  validates :uid, presence: true

  def generate_id
    uid
  end

  def update_from_hash(data)
    self.uid = data[:email]
    self.name = [data[:firstname], data[:lastname]].join(' ').chomp(' ')
    self
  end
end
