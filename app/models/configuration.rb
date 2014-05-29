class Configuration < ActiveRecord::Base
  self.inheritance_column = 'class' # STI not used

  def self.for(user, type)
    groups = user.group_ids
    # TODO: Rewrite into one query?
    global_configuration = Configuration.where(type: type).where(group_id: nil, user_id: nil).first
    group_configuration = Configuration.where(type: type).where(:group_id => groups).first
    user_configuration = Configuration.where(type: type).where(user_id: user.id).first
    all = [global_configuration, group_configuration, user_configuration].select(&:present?) # Order important
    created_at = all.max_by(&:created_at).created_at unless all.empty?
    updated_at = all.max_by(&:updated_at).updated_at unless all.empty?
    configurations = all.map!{|c| c.configuration}
    configuration = configurations.inject(&:merge)
    configuration ||= {}
    {
      :type => type,
      :configuration => configuration,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end

end
