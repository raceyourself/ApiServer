class BotWorker
  include Sidekiq::Worker
    
  def perform(bot_id, activity)
    bot = User.find(bot_id)
    return unless bot
    raise 'I am not a bot!' if /bot[^@]+@raceyourself.com/.match(bot.email).nil?

    activity_level = bot.profile['activity_level']
    fitness_level = bot.profile['fitness_level']

    case activity
    when 'wake up'
      BotWorker.perform_in(Random.rand(8).hours, bot.id, 'run')
      BotWorker.perform_in(Random.rand(8).hours, bot.id, 'challenge')
    when 'run'
      do_run(bot, fitness_level)
    when 'challenge'
      do_challenge(bot, fitness_level)
    end
  end
    
  # Schedule bots' wake up calls
  def self.wake_up
    Rails.logger.info "Waking up Race Yourself bots.."
    User.where("email LIKE 'bot%@raceyourself.com'").each do |bot|
      BotWorker.perform_at(Time.parse(bot.profile['wake_up_time']), bot.id, 'wake up') if bot.profile.has_key?('wake_up_time')
    end
  end

  # Wake up bots on app init if they aren't already running
  def self.initialize
    wake_up if Sidekiq.redis { |r| r.llen "queue:default" } == 0
  end

  private

  def do_run(bot, fitness_level)
    Rails.logger.info "#{bot.email} is doing a run at #{fitness_level} level"
  end

  def do_challenge(bot, fitness_level)
    Rails.logger.info "#{bot.email} is doing a challenge at #{fitness_level} level"
  end

end
