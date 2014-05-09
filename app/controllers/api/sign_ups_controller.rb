module Api
  class SignUpsController < BaseController

    def create
      errors = {}
      # By code
      invite = Invite.where(:code => params[:invite_code]).first
      # By invited e-mail
      invite = Invite.where(:identity_type => 'email').where(:identity_uid => params[:email]).first unless invite
      
      errors[:invite_code] = ['missing'] unless invite

      if errors.empty?
        user = User.new(
                username: params[:username],
                name: params[:name],
                password: params[:password],
                email: params[:email],
                image: params[:image],
                gender: params[:gender],
                timezone: params[:timezone],
                profile: params[:profile]
        )
        if user.valid?
          user.skip_confirmation!
          user.save!
          
          # Destroy accepted invite
          invite.destroy if invite
        else
          errors.merge! user.errors.messages
          errors[:user] = ['is invalid'] if errors.empty?
        end
      end

      if errors.empty?
        expose({:success => true, :user => user})
      else
        expose({:errors => errors})
      end
    end

  end
end
