class EmailIdentity < Identity
  field :email, type: String

  validates :email, presence: true

  def generate_id
    email
  end
end
