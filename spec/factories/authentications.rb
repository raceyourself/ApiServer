# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    user_id 1
    provider "MyString"
    uid "MyString"
    provider_data "MyText"
    email "MyString"
    token "MyString"
    token_secret "MyString"
    token_expires false
    token_expires_at "2013-10-16 21:32:02"
    refresh_token "MyString"
  end
end
