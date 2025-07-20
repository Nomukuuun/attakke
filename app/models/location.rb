class Location < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }

  has_many :stocks, dependent: :destroy
end
