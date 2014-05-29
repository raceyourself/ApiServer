class ErrorWorker
  include Sidekiq::Worker
    
  def perform
    this_is_an_error!
  end
    
end
