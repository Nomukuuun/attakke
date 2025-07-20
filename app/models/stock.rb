class Stock < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :model, presence: true, length: { maximum: 255 }

  belongs_to :user
  belongs_to :location
  has_many :histories, dependent: :destroy
end
