class CreateSurveyBetaInsights < ActiveRecord::Migration
  def change
    create_table :survey_beta_insights do |t|
      t.integer :response_id
      t.datetime :time_started
      t.datetime :time_submitted
      t.string :status
      t.text :contact_id
      t.text :legacy_comments
      t.text :comments
      t.text :language
      t.text :referrer
      t.text :extended_referrer
      t.text :session_id
      t.text :user_agent
      t.text :extended_user_agent
      t.string :ip_address
      t.float :longitude
      t.float :latitude
      t.string :country_auto
      t.string :city
      t.string :region
      t.string :post_code
      t.string :mobile_device_1
      t.string :mobile_device_2
      t.string :wearable_glass
      t.string :wearable_other_title
      t.string :wearable_other
      t.string :running_fitness
      t.string :cycling_fitness
      t.string :workout_fitness
      t.string :goal_faster
      t.string :goal_further
      t.string :goal_slimmer
      t.string :goal_stronger
      t.string :goal_happier
      t.string :goal_live_longer
      t.string :goal_manage_condition
      t.string :goal_other_title
      t.string :goal_other
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :url
      t.string :gender
      t.string :age_group
      t.string :country_as_entered

      t.timestamps
    end
  end
end
