class SurveyBetaInsight < ActiveRecord::Base

  # try to create a user based on the new survey repsonse
  before_create :create_user, :on => [:create]

  def create_user

    return if (self.email == nil)  # can't create user if we don't have their email

    logger.info("Creating a new user account for survey respondent " + self.email)

    u = User.new
    u.email = self.email
    u.username = self.email
    if (!self.first_name.nil? && !self.last_name.nil?)
      u.name = self.first_name + " " + self.last_name
    end
    u.gender = if self.gender == "Male" then "m" elsif self.gender == "Female" then "f" else nil end
    u.profile = {
      "first_name" => self.first_name,
      "last_name" => self.last_name,
      "phone_number" => self.phone_number,
      "url" => self.url,
      "age_group" => self.age_group,
      "latitude" => self.latitude,
      "longitude" => self.longitude,
      "country" => self.country_auto,
      "city" => self.city,
      "post_code" => self.post_code,
      "devices_reported" => [self.mobile_device_1, self.mobile_device_2, self.wearable_glass, self.wearable_other].compact,
      "running_fitness" => self.running_fitness,
      "cycling_fitness" => self.cycling_fitness,
      "workout_fitness" => self.workout_fitness,
      "goals" => [self.goal_faster, self.goal_further, self.goal_slimmer, self.goal_stronger, self.goal_happier, self.goal_live_longer, self.goal_manage_condition, self.goal_other].compact
    }
    u.skip_confirmation!

    begin
      u.save(:validate => false)
      self.contact_id = u.id  # store the new user_id so we can join things up later
      #self.save!
      logger.info("User account created for " + self.email + ", ID is " + self.contact_id.to_s)
    rescue ActiveRecord::RecordInvalid => e1
      logger.info("User account creation failed! " + e1.to_s)
    rescue ActiveRecord::RecordNotUnique => e2
      # should probably update existing record...
      logger.info("User account creation failed! " + e2.to_s)
    end

  end

end
