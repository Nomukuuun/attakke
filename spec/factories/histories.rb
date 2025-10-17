FactoryBot.define do
  factory :history do
    association :stock, factory: :stock

    # デフォルトはexistenceモデル用
    exist_quantity { 1 }
    num_quantity { nil }
    status { :purchase }
    recording_date { Date.today }

    trait :for_number do
      after(:build) do |history|
        history.stock.model = :number
        history.exist_quantity = nil
        history.num_quantity = 1
      end
    end
  end
end
