class Stock < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :model, presence: true

  enum :model, { existence: 0, number: 1 }

  belongs_to :user
  belongs_to :location
  has_many :histories, dependent: :destroy

  accepts_nested_attributes_for :histories

  # indexアクション用のクラスメソッド
  def self.joins_latest_history(latest_history)
    joins("LEFT JOIN (#{latest_history.to_sql}) AS latest_history ON latest_history.stock_id = stocks.id")
          .select("stocks.*, latest_history.recording_date AS latest_recording_date, latest_history.exist_quantity AS latest_exist_quantity, latest_history.num_quantity AS latest_num_quantity")
  end

  # index画面でフィルタリングに使用するscope
  scope :order_asc_model_and_name, -> { order(:model ,:name) }
  scope :in_stocks, -> { where("COALESCE(latest_history.exist_quantity, 0) > 0 OR COALESCE(latest_history.num_quantity, 0) > 0") }
  scope :out_of_stocks, -> { where("COALESCE(latest_history.exist_quantity, 0) = 0 AND COALESCE(latest_history.num_quantity, 0) = 0") }

  # index画面で〇日前と表示するためのメソッド
  def number_of_days_elapsed
    return "履歴なし" unless latest_recording_date

    elapsed_days = Date.today - latest_recording_date.to_date
    elapsed_days.to_i == 0 ? "今日" : "#{elapsed_days.to_i}日前"
  end
end
