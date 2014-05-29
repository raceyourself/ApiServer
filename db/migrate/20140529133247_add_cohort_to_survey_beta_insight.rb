class AddCohortToSurveyBetaInsight < ActiveRecord::Migration
  def change
    add_column :survey_beta_insights, :cohort, :string
  end
end
