class Templete < ApplicationRecord
  validates :tag, presence: true
  validates :location_name, presence: true
  validates :stock_name, presence: true
  validates :stock_model, presence: true
end
