require 'file_size_validator' 
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
  has_many :game_states, :dependent => :destroy

  mount_uploader :image, AvatarUploader
  validates :image, 
    :file_size => { 
      :maximum => 0.5.megabytes.to_i 
    }
 
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
      methods: :points,
      except: :image
    }.update(options || {})
    hash = super(options)
    hash['image'] = self.image.url
    hash
  end

  def pretty_segmentation_characteristics
    d = {
      "Age group" => self.profile["age_group"],
      "Gender" => self.gender.present? ? (self.gender.downcase  == "m" ? "male" : self.gender.downcase == "f" ? "female" : nil) : nil,
      "Country" => self.profile["country"],
      "Cohort" => self.cohort
    }
  end

  after_commit :send_analytics, :on => [:create, :update], :if => Proc.new { |record|
    record.previous_changes.except("updated_at").except("sync_timestamp").length > 0  # don't bother sending if the only update was the timestamp
  }

  def send_analytics
    logger.info(self.name.to_s + " (userId " + self.id.to_s  + ") profile info updated: " + self.previous_changes.inspect)
    
    AnalyticsRuby.identify(
      user_id: self.id,
      traits: {
        # personal data
        email: self.email,
        cohort: self.cohort,
        username: self.username,  #unique
        name: self.name,  #free text
        #firstName: self.name.present? ? self.name.strip.split("\s").first : nil,  #needed for mailChimp
        #lastName: self.name.present? ? self.name.strip.split("\s").last : nil,  #needed for mailChimp
        firstname: self.profile["first_name"],
        lastname: self.profile["last_name"],
        fname: self.profile["first_name"],
        lname: self.profile["last_name"],
        gender: self.gender.present? ? (self.gender.downcase  == "m" ? "male" : self.gender.downcase == "f" ? "female" : nil) : nil,  #mailchimp and trak both want the full word
        age_group: self.profile["age_group"],
        profile: self.profile,
        image: self.image,
        avatar_url: self.image,  #for trak.io
        website: self.profile["url"],
        phone: self.profile["phone_number"],
        devices_r: self.profile["devices_reported"].present? ? self.profile["devices_reported"].join(", ") : nil,

        # location
        latlng: self.profile["latitude"].to_s + "," + self.profile["longitude"].to_s,
        address: { country: self.profile["country"] , city: self.profile["city"], postalCode: self.profile["post_code"] },
        country: self.profile["country"],

        # reported fitness preferences
        running: self.profile["running_fitness"],
        cycling: self.profile["cycling_fitness"],
        workout: self.profile["workout_fitness"],
        goals: self.profile["goals"].present? ? self.profile["goals"].join(", ") : nil,
       
        # activity in the app
        challenges: self.challenges.count,
        tracks: self.tracks.count,
        devices: devices.map { |d| d.manufacturer + " " + d.model }.sort.join(", "),
        milestones: self.ux_milestones.nil? || !self.ux_milestones.is_a?(Hash) ? "" : self.ux_milestones.keys.map{|k| k.titleize}.join(", "),  # snake_case to Caps And Spaces
 
        # groups we've added the user to
        groups: groups.map { |g| g.name }.sort.join(", ")
      },
      timestamp: self.created_at
    )

    logger.info("New profile info sent to segment.io")

  end

  def update_ux_milestones(milestone_names = [])
    
    # initialize if nil
    self.ux_milestones = {} if self.ux_milestones.nil? || !self.ux_milestones.is_a?(Hash)
    
    # just the ones we don't already have
    for m in (milestone_names - self.ux_milestones.keys)
      # get the first event of type m
      e = self.events.where("data::json->>'event_name' = ?", m).order("ts asc").first
      if (!e.nil?)
        logger.info(self.email + " achieved milestone " + m + ", updating their profile")
        self.ux_milestones_will_change!  # updating variable in place, so need to flag change for activerecord to notice it
        self.ux_milestones = {} if self.ux_milestones.nil?  # initialize to empty hash
        self.ux_milestones[m] = Time.at(e.ts.to_f/1000.0)
      end
    end
    self.save! if changed?

  end

end
