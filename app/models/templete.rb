class Templete < ApplicationRecord
  validates :tag, presence: true
  validates :location_name, presence: true
  validates :stock_name, presence: true
  validates :stock_model, presence: true

  scope :by_location_name, ->(location_name) { where(location_name: location_name) }
end
