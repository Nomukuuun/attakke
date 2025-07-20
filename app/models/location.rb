class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }

  enum status: { purchase: 0, consumption: 1 }

  has_many :stocks, dependent: :destroy
end
