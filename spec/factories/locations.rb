FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "場所#{n}" }
    association :user, factory: :user
  end
end

