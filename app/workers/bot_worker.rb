class BotWorker
  include Sidekiq::Worker
    
  def perform(bot_id, activity, opts={})
    bot = User.find(bot_id)
    return unless bot
    raise 'I am not a bot!' if /bot[^@]+@raceyourself.com/.match(bot.email).nil?

    activity_level = bot.profile['activity_level']
    fitness_level = bot.profile['fitness_level']

    case activity
    when 'wake up'
      BotWorker.perform_in(Random.rand(8).hours, bot.id, 'run', opts)
      BotWorker.perform_in(Random.rand(8).hours, bot.id, 'challenge', opts)
    when 'run'
      do_run(bot, fitness_level, opts)
    when 'challenge'
      do_challenge(bot, fitness_level, opts)
    end
  end
    
  # Schedule bots' wake up calls
  def self.wake_up
    Rails.logger.info "Waking up Race Yourself bots.."
    User.where("email LIKE 'bot%@raceyourself.com'").each do |bot|
      next unless bot.profile.has_key?('wake_up_time')
      wake_up_time = Time.parse(bot.profile['wake_up_time'])
      BotWorker.perform_at(wake_up_time, bot.id, 'wake up') if wake_up_time > Time.now
    end
  end

  # Wake up bots on app init if they aren't already running
  def self.initialize
    wake_up if Sidekiq.redis { |r| r.llen("queue:default") == 0 && r.zrange("schedule", 0, -1).empty? }
  end

  private

  def do_run(bot, fitness_level, opts={})
    Rails.logger.info "#{bot.email} is doing a run at #{fitness_level} level"
    configuration = Configuration.where(type: '_internal', user_id: nil, group_id: nil).first.configuration
    raise "Fitness levels not configured" unless configuration['fitness_levels']
    range = configuration['fitness_levels'][fitness_level]
    raise "Fitness level: #{fitness_level} not configured" unless range && range['max'] && range['min']
    max = range['max'].to_f
    min = range['min'].to_f
    diff = max - min
    diff = 1 if diff < 0
    pace = min + Random.rand(diff)
    track = nil
    ActiveRecord::Base.transaction do
      device = Device.where(user_id: bot.id).last
      device = Device.create!(user_id: bot.id, 
                              manufacturer: "Mom's Friendly Robot Company", 
                              model: 'Bot 2000',
                              glassfit_version: 0) unless device

      speed = 1000 * 1.0/(pace*60) # min/km -> m/s
      mins = 5 + 5 * Random.rand(6)
      mins = opts['time'] if opts.has_key?('time')
      time = mins * 60 + Random.rand(300) # seconds
      distance = speed * time
      track = Track.create!(device_id: device.id, track_id: Random.rand(99999), user_id: bot.id,
                            public: true, ts: (Time.now.to_f*1000).to_i,
                            distance: distance, time: time*1000)
      id = track.track_id*1000
      timestamp = Time.now - time.seconds # backdate so that we don't end up with times in the future
      (1..time).step(10) do |t|
        id = id + 1
        timestamp = timestamp + t.seconds
        lng = 0
        lat = (speed * t)/111229.0
        bearing = 0
        Position.create!(device_id: track.device_id, track_id: track.track_id, 
                         position_id: id, user_id: bot.id,
                         state_id: 1,
                         gps_ts: (timestamp.to_f*1000).to_i,
                         device_ts: (timestamp.to_f*1000).to_i,
                         lng: lng,
                         lat: lat,
                         alt: 0,
                         bearing: bearing,
                         speed: speed,
                         epe: 25)
      end
    end
    track
  end

  def do_challenge(bot, fitness_level, opts={})
    Rails.logger.info "#{bot.email} is doing a challenge at #{fitness_level} level"
    group = Group.where(name: "Victims").first
    return unless group
    victim_id = group.users.pluck(:id).sample
    return unless victim_id
    
    Rails.logger.info "#{bot.email} is challenging user #{victim_id}"
    # TODO: Don't duplicate challenging logic here
    time = 5 + 5 * Random.rand(6)
    track = do_run(bot, fitness_level, {time: time})
    return unless track
    ActiveRecord::Base.transaction do
      challenge = DurationChallenge.create!(public: true, creator_id: bot.id, duration: time*60, distance: 0, 
                                            name: 'Disco fever', 
                                            description: 'First to the finish line gets to go clubbing baby seals!', 
                                            points_awarded: 88, prize: 'A fancy new coat')
      target = User.find(victim_id)
      challenge.attempts << track
      challenge.subscribers << bot
      challenge.subscribers << target
      target.notifications.create!(:message => {
                                      :type => 'challenge',
                                      :from => bot.id,
                                      :to => victim_id,
                                      :device_id => challenge.device_id,
                                      :challenge_id => challenge.challenge_id,
                                      :challenge_type => challenge.challenge_type,
                                      :taunt => '001111001010111010010011!'
                                   })
      PushNotificationWorker.perform_async(target.id, {
                                            :title => bot.to_s + ' has challenged you!',
                                            :text => 'Click to race!',
                                            :image => bot.image_url
                                           })
    end
  end

end
