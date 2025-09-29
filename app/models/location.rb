class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50, message: "は%{count}字以内で入力してください" }, uniqueness: { scope: :user_id }

  has_many :stocks, dependent: :destroy
  belongs_to :user
end
