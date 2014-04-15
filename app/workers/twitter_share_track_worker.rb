class TwitterShareTrackWorker < ShareTrackWorker
    
  def share(user, track, message)
    auth = Authentication.where(provider: 'twitter', user_id: user.id).first
    raise "User has not authenticated with twitter" if auth.nil?
    raise "User has not authorized share permissions for twitter" if auth.permissions !~ /share/
    client = Twitter::REST::Client.new(:consumer_key => CONFIG[:twitter][:client_id],
                                                                   :consumer_secret => CONFIG[:twitter][:client_secret],
                                                                   :oauth_token => auth.token,
                                                                   :oauth_token_secret => auth.token_secret)
    # TODO: Generate URL to tweet
    client.update("Testing 1, 2, 3")
  end
    
end
