class HelloWorker
  include Sidekiq::Worker
    
  def perform(from_id, to_id)
    from = User.find(from_id)
    to = User.find(to_id)
    return unless from && to

    do_challenge(from, to)
  end

  def do_challenge(from, to)
    Rails.logger.info "#{from.email} is sending a welcome challenge to #{to.email}"
    
    # TODO: Don't duplicate challenging logic here
    time = 5
    track = from.tracks.where('time > ? AND distance > 0', time*60*1000).first
    return unless track
    ActiveRecord::Base.transaction do
      challenge = DurationChallenge.create!(public: true, creator_id: from.id, duration: time*60, distance: 0, 
                                            name: 'Welcome!', 
                                            description: 'Get going with this challenge!', 
                                            points_awarded: 1000)
      challenge.attempts << track
      challenge.subscribers << from
      challenge.subscribers << to
      to.notifications.create!(:message => {
                                      :type => 'challenge',
                                      :from => from.id,
                                      :to => to.id,
                                      :device_id => challenge.device_id,
                                      :challenge_id => challenge.challenge_id,
                                      :challenge_type => challenge.challenge_type,
                                      :taunt => 'Welcome!'
                                   })
      PushNotificationWorker.perform_async(to.id, {
                                            :title => from.to_s + ' has challenged you!',
                                            :text => 'Click to race!'
                                           })
    end
  end

end
