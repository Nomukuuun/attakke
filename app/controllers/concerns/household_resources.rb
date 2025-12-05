# 各コントローラでログインユーザーの世帯リソースを取得する記述が重複しているためこちらに切り出し

module HouseholdResources
  extend ActiveSupport::Concern

  private

  def household_stocks
    current_user.household_stocks
  end

  def household_locations
    current_user.household_locations
  end
end
