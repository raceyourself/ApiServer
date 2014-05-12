class User < ActiveRecord::Base
  include RocketPants::Cacheable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :timeoutable, :omniauthable,
         omniauth_providers: [:facebook, :twitter, :gplus]

  # must be below devise
  include Concerns::Authentication
  include Concerns::UserAssociations

  # associations
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups
  has_many :game_states

  # TODO: Add photo field (populate from identities if null)

  def has_role?(role)
    role = role.to_s.downcase.to_sym
    roles.any?{|r| r.name.to_s.downcase.to_sym == role}
  end

  def to_s
    username.present? ? username : email
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
      self.errors[:password] << "can't be blank" if password.blank?
      self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
      self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
      password == password_confirmation && !password.blank?
  end

  def points
    latest = latest_transaction()
    if latest
      latest.points_balance
    else
      0
    end
  end

  def latest_transaction
    self.transactions.order(updated_at: :desc, ts: :desc).first
  end

  def peers
    groups = self.group_ids
    if groups.empty?
      User.all
    else
      User.find(:all, :include => :groups, :conditions => {:groups => {:id => groups}})
    end
  end

  def exchange_access_token(provider, token)
    server_token = nil

    case provider
    when 'facebook'
      oauth = Koala::Facebook::OAuth.new(CONFIG[:facebook][:client_id], CONFIG[:facebook][:client_secret])
      server_token = oauth.exchange_access_token_info(token)
    end

    server_token
  end

  def serializable_hash(options = {})
    options = {
      methods: :points
    }.update(options)
    super(options)
  end

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    logger.info(self.name.to_s + " (userId " + self.id.to_s  + ") profile info updated and sent to segment.io")
    
    Analytics.identify(
      user_id: self.id,
      traits: {
        email: self.email,
        username: self.username,  #unique
        name: self.name,  #free text
        firstName: self.name.present? ? self.name.strip.split("\s").first : nil,  #needed for mailChimp
        lastName: self.name.present? ? self.name.strip.split("\s").last : nil,  #needed for mailChimp
        gender: self.gender.present? ? (self.gender.downcase  == "m" ? "male" : self.gender.downcase == "f" ? "female" : nil) : nil,  #mailchimp and trak both want the full word
        profile: self.profile,
        image: self.image,
        avatar_url: self.image,  #for trak.io

        challenges: self.challenges.count,
        tracks: self.tracks.count,
        devices: devices.map { |d| d.manufacturer + " " + d.model }.sort.join(", "),
        groups: groups.map { |g| g.name }.sort.join(", ")
      },
      timestamp: self.created_at
    )

  end

end
