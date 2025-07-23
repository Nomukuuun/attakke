class History < ApplicationRecord
  validates :quantity, presence: true, length: { maximum: 255 }
  validates :status, presence:true, length: { maximum: 255 }
  validates :recording_date, presence: true

  enum status: { purchase: 0, consumption: 1 }

  belongs_to :stock
end
