FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "ユーザー#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }

    trait :google do
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "uid-#{n}" }
    end
  end
end
