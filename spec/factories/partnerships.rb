FactoryBot.define do
  factory :partnership do
    association :user, factory: :user
    association :partner, factory: :user
    status { :sended }
  end
end
