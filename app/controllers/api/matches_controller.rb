module Api
  class MatchesController < BaseController
    doorkeeper_for :all

    def index
      # Return a matrix of public track matches (N per bucket)
      matches = {}
      ['out of shape', 'average', 'athletic', 'elite'].each do |fitness_level|
        matches[fitness_level] = matches(fitness_level, 10)
      end
      expose matches
    end

    def show
      expose matches(params[:id], 25)
    end

    def matches(fitness_level, bucket_size)
      fitness_levels = ::Configuration.where(type: '_internal', user_id: nil, group_id: nil).first_or_create(configuration: {})[:configuration]['fitness_levels'] || {}
      pace = fitness_levels[fitness_level]
      Rails.logger.error "No min/max pace configured for fitness level #{fitness_level}!" and return {} unless pace
      matches = {}
      # Can be rewritten as a single select + group_by if we don't need an exact per-bucket size
      (5..60).step(5) do |duration|
        matches[duration] = Track.where(:public => true)
                                 .where('distance > 0')
                                 .where('(time*1000/distance)/60 >= ? AND (time*1000/distance)/60 < ?', pace['min'], pace['max'])
                                 .where('time >= ? AND time < ?', duration*60, (duration+5)*60)
                                 .where(%Q((device_id, track_id) NOT IN (
                                           SELECT device_id, track_id 
                                           FROM matched_tracks WHERE user_id = ?
                                 )), user.id)
                                 .limit(bucket_size)
      end
      matches
    end

  end
end
