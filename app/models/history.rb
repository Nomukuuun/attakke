class History < ApplicationRecord
  validates :exist_quantity, inclusion: { in: [0, 1] }
  validates :num_quantity, numericality: { greater_than_or_equal_to: 0, less_than: 100 }
  validates :status, presence:true, length: { maximum: 255 }
  validates :recording_date, presence: true
  validate :essential_quantity
  enum status: { purchase: 0, consumption: 1 }

  belongs_to :stock

  private

  # ストック型と一致する数量が入力されているか検査
  def essential_quantity
    if stock.existence?
      errors.add(:exist_quantity, "が入力されていません") if exist_quantity.nil?
    elsif stock.number?
      errors.add(:num_quantity, "が入力されていません") if num_quantity.nil?
    end
  end
end
