class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50, message: "は%{count}字以内で入力してください" }
  validate :household_unique_name

  has_many :stocks, dependent: :destroy
  belongs_to :user

  private

  def household_unique_name
    return if user.blank?

    # userの世帯に属するユーザーたちのidを配列で取得
    user_ids = user.household_user_ids

    # 自身を除く世帯の保管場所内で name が重複していないか
    conflict = self.class
                .where(user_id: user_ids, name: name)
                .where.not(id: id)

    errors.add(:name, "は世帯で既に使われています") if conflict.exists?
  end
end
