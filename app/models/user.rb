class User < ActiveRecord::Base
  include Authentication

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :omniauthable,
         omniauth_providers: [:facebook, :twitter, :linkedin, :google]


end