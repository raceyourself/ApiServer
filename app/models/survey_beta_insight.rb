class SurveyBetaInsight < ActiveRecord::Base

  after_commit :create_user, :on => [:create, :update]

  def create_user

    return if (self.email == nil)  # can't create user if we don't have their email

    logger.info(self.email + " completed the beta insight survey, creating user account")

    u = User.new(:email => self.email, :username => self.email, :name => self.first_name + " " + self.last_name)
    u.gender = if self.gender = "Male" then "m" elsif self.gender = "Female" then "f" else nil end
    u.profile = {
      :first_name => self.first_name,
      :last_name => self.last_name,
      :phone_number => self.phone_number,
      :url => self.url,
      :age_group => self.age_group,
      :latititude => self.latitude,
      :longitude => self.longitude,
      :country => self.country_auto,
      :devices_reported => [self.mobile_device_1, self.mobile_device_2].compact,
      :running_fitness => self.running_fitness,
      :cycling_fitness => self.cycling_fitness,
      :workout => self.workout_fitness,
      :goals => [self.goal_faster, self.goal_further, self.goal_slimmer, self.goal_stronger, self.goal_happier, self.goal_live_longer, self.goal_manage_condition, self.goal_other].compact
    }
    puts "ID is " + u.id
    u.skip_confirmation!
    id = u.save!

    self.contact_id = id  # store the new user_id so we can join things up later
    self.save!

    logger.info("User account created")

  end

end
