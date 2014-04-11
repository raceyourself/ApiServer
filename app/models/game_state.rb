class GameState < ActiveRecord::Base
  belongs_to :game

  def self.last_modified
    GameState.maximum(:updated_at)
  end

  def self.for(user, game_id)
    groups = user.group_ids
    # TODO: Rewrite into one query?
    states = []
    states.push GameState.where(game_id: game_id).where(group_id: nil, user_id: nil).first
    states.concat GameState.where(game_id: game_id).where(:group_id => groups)
    states.push GameState.where(game_id: game_id).where(user_id: user.id).first
    states = states.select(&:present?)
    created_at = states.max_by(&:created_at).created_at
    updated_at = states.max_by(&:updated_at).updated_at
    states = states.map do |s|
      hash = s.attributes
      hash.delete_if{ |k,v| v.nil? }
      hash
    end
    state = states.inject(&:merge)
    state['created_at'] = created_at
    state['updated_at'] = updated_at
    state.except('id', 'group_id', 'user_id')
  end

end
