module Concerns
  module UserAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = [:devices, :positions, :tracks, :notifications, :challenges, :events, :games]

    included do
      has_many :devices
      has_many :tracks
      has_many :transactions
      has_many :notifications
      has_many :events
      has_many :challenge_subscribers
      has_many :challenges, :through => :challenge_subscribers
      
      define_method :games do
        # TODO work out how to simplify this query without doing the user-group-global game state merge
        # in Ruby (too many object instantiations). Couldn't find any nice neat way of doing it in SQL...
        # Maybe this would be more maintainable as a stored procedure?
        Game.joins(:menu_items).joins(:game_states).joins("inner join (
          select
            coalesce(group_user_games.game_id, global_games.game_id) game_id,
            coalesce(group_user_games.user_enabled, group_user_games.group_enabled, global_games.enabled) enabled,
            coalesce(group_user_games.user_locked, group_user_games.group_locked, global_games.locked) locked,
            coalesce(group_user_games.user_state_id, group_user_games.group_state_id, global_games.state_id) state_id
          from
          (
            select
              coalesce(user_games.user_id, group_games.user_id) user_id,
              coalesce(user_games.game_id, group_games.game_id) game_id,
              user_games.enabled user_enabled,
              group_games.enabled group_enabled,
              user_games.locked user_locked,
              group_games.locked group_locked,
              user_games.state_id user_state_id,
              group_games.state_id group_state_id
            from
            (--Games associated with user
              select gs.id state_id, gs.user_id, gs.game_id, gs.enabled, gs.locked
              from game_states gs
              where gs.user_id = %d
            ) user_games
            full outer join
            (--Game states associated with user via group -- group by game
              select max(gs.id) state_id, gu.user_id, gs.game_id, bool_or(gs.enabled) enabled, bool_and(gs.locked) locked
              from game_states gs
              join groups gr
              on gs.group_id = gr.id
              join groups_users gu
              on gr.id = gu.group_id
              where gu.user_id = %d
              group by gu.user_id, gs.game_id
            ) group_games
            on user_games.game_id = group_games.game_id
          ) group_user_games
          full outer join
          (--Game states at global level
            select gs.id state_id, gs.game_id, gs.enabled, gs.locked
            from game_states gs
            where gs.group_id is null
            and gs.user_id is null
          ) global_games
          on group_user_games.game_id = global_games.game_id
        ) merged_states on game_states.id = merged_states.state_id" % [id, id]).select("games.id, games.name, games.description, games.tier, games.price_in_points, games.price_in_gems, games.scene_name, games.type, game_states.created_at, game_states.updated_at, games.deleted_at, merged_states.enabled, merged_states.locked, menu_items.icon, menu_items.column, menu_items.row")
      end
      
      define_method :friends do
        Friendship.joins(:identity).where(:identities => {:user_id => id})
      end

      define_method :positions do
        Position.where(user_id: id).where('state_id >= 0')
      end
      
    end #included

  end
end 
