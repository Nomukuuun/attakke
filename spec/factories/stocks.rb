FactoryBot.define do
  factory :stock do
    sequence(:name) { |n| "ストック#{n}" }
    model { :existence }

    association :user, factory: :user
    association :location, factory: :location

    after(:build) do |stock|
      # locationのuserとstockのuserを一致させる
      stock.location.user = stock.user if stock.location && stock.user && stock.location.user != stock.user
    end
  end
end
