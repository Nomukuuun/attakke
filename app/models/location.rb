class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true

  has_many :stocks, dependent: :destroy
  belongs_to :user
end
