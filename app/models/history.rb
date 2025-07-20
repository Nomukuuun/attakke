class History < ApplicationRecord
  validates :stock, presence: true, length: { maximum: 255 }
  validates :status, presence:true, length: { maximum: 255 }
  validates :recording_date, presence: true

  belongs_to :stock
end
