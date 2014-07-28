module Api
  class ResetController < BaseController
    
    def password
      user = User.where(email: params[:email]).first
      unless user
        expose({:success => false})
        return
      end
      user.send_reset_password_instructions
      expose({:success => true})
    end

  end
end
