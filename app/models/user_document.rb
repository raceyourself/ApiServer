class UserDocument
  include ::Mongoid::Document
  include ::Mongoid::Timestamps::Updated
  include ::Mongoid::Paranoia
  # fields
  field :user_id, type: Integer
  # indexes
  index user_id: 1
  # validations
  validates :user_id, presence: true

  # TODO: Only set_updated_at if values changed
  #       (in friendship's case, also when friend changes)
  before_upsert :set_updated_at

  def user
    User.where(id: user_id).first
  end

  def merge
    self.upsert if self.valid?
  end

  def serializable_hash(options = {})
    # Return plain attributes if no options or default rocket_pants options
    if options.nil? || options.except(:url_options, :root, :compact).empty?
      attributes
    else
      super(options)
    end
  end

end
