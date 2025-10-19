class Stock < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :model, presence: true
  validates :purchase_target, inclusion: { in: [ true, false ] }

  enum :model, { existence: 0, number: 1 }

  belongs_to :user
  belongs_to :location
  has_many :histories, dependent: :destroy

  accepts_nested_attributes_for :histories

  # フィルタリングに使用するscope
  # 使用しない型の数量はnilで保存しているため、COALESCEで０に置換して判定している
  scope :order_asc_model_and_name, -> { order(:model, :name) }
  scope :in_stocks, -> { where("COALESCE(latest_history.exist_quantity, 0) > 0 OR COALESCE(latest_history.num_quantity, 0) > 0").where(purchase_target: false) }
  scope :out_of_stocks, -> { where("COALESCE(latest_history.exist_quantity, 0) = 0 AND COALESCE(latest_history.num_quantity, 0) = 0 OR purchase_target = ?", true) }

  # ransackのv4系から必要になった検索を許可するカラムの指定
  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end

  # 各ストックに最新履歴を連結する
  def self.joins_latest_history(latest_history)
    joins("LEFT JOIN (#{latest_history.to_sql}) AS latest_history ON latest_history.stock_id = stocks.id")
    .select("stocks.*, latest_history.recording_date AS latest_recording_date, latest_history.exist_quantity AS latest_exist_quantity, latest_history.num_quantity AS latest_num_quantity")
  end
end
