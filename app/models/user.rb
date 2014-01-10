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
  include Concerns::DocumentAssociations

  # associations
  has_and_belongs_to_many :roles

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
    return 0
    #latest = self.transactions.desc(:ts).first
    #if latest
    #  latest.points_balance
    #else
    #  0
    #end
  end

end
