class InvitedController < ApplicationController

  def show
    @invite = Invite.where(code: params[:invite_code]).first
  end

  def continue
    session['invite_code'] = params[:invite_code]
    session['device'] = params[:device]
    redirect_to omniauth_authorize_path(:user, params[:provider]) 
  end

end
