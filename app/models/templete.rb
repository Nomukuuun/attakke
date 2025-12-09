class Templete < ApplicationRecord
  validates :tag, presence: true
  validates :location_name, presence: true
  validates :stock_name, presence: true
  validates :stock_model, presence: true

  scope :with_location_name, ->(location_name) { where(location_name: location_name) }

  # indexアクションで保管場所名の配列を作成するために使用
  def self.prefixed_location_names_array
    group(:location_name)
      .minimum(:id)
      .sort_by { |_, id| id }                # id を昇順に整列
      .map { |name, _| "<テンプレ> #{name}" } # プレフィックス追加
  end
end
