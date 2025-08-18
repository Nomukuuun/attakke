class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id }

  has_many :stocks, dependent: :destroy
  belongs_to :user
end
