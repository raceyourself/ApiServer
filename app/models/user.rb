class User < ActiveRecord::Base
  include RocketPants::Cacheable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :omniauthable,
         omniauth_providers: [:facebook, :twitter, :linkedin, :google]

  # must be below devise
  include Concerns::Authentication

  # associations
  has_and_belongs_to_many :roles


  def has_role?(role)
    role = role.to_s.downcase.to_sym
    roles.any?{|r| r.name.to_s.downcase.to_sym == role}
  end

end