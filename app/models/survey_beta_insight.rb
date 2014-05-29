class SurveyBetaInsight < ActiveRecord::Base

  # try to create a user based on the new survey repsonse
  before_create :create_user, :on => [:create]

  def create_user
    return true if (self.email == nil)  # can't create user if we don't have their email
    existing = User.where(email: self.email).first
    if existing
      logger.info("Linking to existing user account for survey respondent " + self.email)
      self.contact_id = existing.id
      return true
    end

    logger.info("Creating a new user account for survey respondent " + self.email)

    u = User.new
    u.email = self.email
    u.cohort = self.cohort
    u.username = self.email
    if (!self.first_name.nil? && !self.last_name.nil?)
      u.name = self.first_name + " " + self.last_name
    end
    u.gender = if self.gender == "Male" then "M" elsif self.gender == "Female" then "F" else 'U' end
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
      "goals" => [self.goal_faster, self.goal_further, self.goal_slimmer, self.goal_stronger, self.goal_happier, self.goal_live_longer, self.goal_manage_condition, self.goal_other].compact # TODO: goal_other_title?
    }
    u.skip_confirmation_notification!

    begin
      u.save!
      self.contact_id = u.id  # store the new user_id so we can join things up later
      logger.info("User account created for " + self.email + ", ID is " + self.contact_id.to_s)
    rescue ActiveRecord::RecordInvalid => e1
      logger.info("User account creation failed! " + e1.to_s)
    rescue ActiveRecord::RecordNotUnique => e2
      # should probably update existing record...
      logger.info("User account creation failed! " + e2.to_s)
    end

    return true
  end

  ## Aliased fields
  
  def country=(value)
    self.country_as_entered = value
  end

  def wearable_devices=(value)
    # Idiotic surveygizmo format
    hash = value
    hash = {0 => value} unless value.is_a?(Hash)
    hash.each do |key,wearable|
      case wearable.downcase
      when 'google glass'
        self.wearable_glass = wearable
      when 'smartwatch [please write the model name in the box]'
        self.wearable_other_title = wearable
      when nil
        # Ignore
      else
        self.wearable_other = '' if self.wearable_other.nil?
        self.wearable_other << '; ' unless self.wearable_other.blank?
        self.wearable_other << wearable
      end
    end
  end

  def goals=(value)
    # Idiotic surveygizmo format
    hash = value
    hash = {0 => value} unless value.is_a?(Hash)
    hash.each do |key,goal|
      case goal.downcase
      when 'go faster'
        self.goal_faster = goal
      when 'go further'
        self.goal_further = goal
      when 'go slimmer'
        self.goal_slimmer = goal
      when 'get stronger'
        self.goal_stronger = goal
      when 'feel happier'
        self.goal_happier = goal
      when 'live longer'
        self.goal_faster = goal
      when 'help manage a chronic condition'
        self.goal_manage_condition = goal
      when 'other'
        self.goal_other_title = goal
      when nil
        # Ignore
      else
        self.goal_other = '' if self.goal_other.nil?
        self.goal_other << '; ' unless self.goal_other.blank?
        self.goal_other << goal
      end
    end
  end

end
