class EchoWorker
  include Sidekiq::Worker
    
  def perform(user_id, message)
    User.where(id: user_id).first.notifications.create(message: message)
  end
    
end
