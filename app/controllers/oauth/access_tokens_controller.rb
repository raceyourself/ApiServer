module Oauth
  class AccessTokensController < AuthedController

    respond_to :html, :json

    before_filter :load_application

    def create
      # TODO this is called from both swagger API and Get access token page, this mapping should not be necessary and the correct data should be
      # sent in the call
      params[:access_grant][:scopes] = [:public] if params[:access_grant][:scopes].is_a?(Array) && params[:access_grant][:scopes].reject{|s| s.blank?}.compact.empty?

      @token = @application.access_tokens.new(
        resource_owner_id: current_user.id, 
        scopes: [params[:access_grant][:scopes]].flatten.join(' '),
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i, 
        use_refresh_token: true
      )
      @token.created_at = Time.now
      @token.save

      respond_to do |format|
        format.js
        format.json { render json: { token: @token.token } }
      end
    end

    def destroy
      @token = @application.access_tokens.find(params[:id])
      @token.revoke
      redirect_to oauth_application_url(@application), notice: "#{@application}: Access token for #{User.find(@token.resource_owner_id)} has been revoked"
    end

    protected

    def load_application
      begin
        @application = relation.where('id = :id', { id: params[:application_id] }).first if params[:application_id].is_a? Integer
        @application = relation.where('uid = :id', { id: params[:application_id] }).first unless @application
      rescue Exception => ex
        # No location given because no resource created
        respond_with({ error: 'Application not found' }, status: 404, location: nil)
      end
    end

    def relation
      Doorkeeper::Application
    end
  end
end
