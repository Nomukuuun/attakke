class Stock < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50, message: "は%{count}字以内で入力してください" }, uniqueness: { scope: :location_id, message: "は同じ保管場所内で既に使われています" }
  validates :model, presence: true
  validates :purchase_target, inclusion: { in: [ true, false ] }

  enum :model, { existence: 0, number: 1 }

  belongs_to :user
  belongs_to :location
  has_many :histories, dependent: :destroy

  accepts_nested_attributes_for :histories

  # 保管場所ごとに並び替えのposition値を管理
  acts_as_list scope: :location

  # 使用しない型の数量はnilで保存しているため、COALESCEで０に置換して判定している
  scope :order_position, -> { order(:position) }
  scope :shopping, -> { where("COALESCE(latest_history.exist_quantity, 0) = 0 AND COALESCE(latest_history.num_quantity, 0) = 0 OR purchase_target = ?", true) }
  scope :not_in_shopping, -> { where("(COALESCE(latest_history.exist_quantity, 0) > 0 OR COALESCE(latest_history.num_quantity, 0) > 0)").where("purchase_target = ?", false) }

  # editアクションでhistoryのインスタンスをセットする
  def build_latest_history
    latest_history = histories.order(id: :desc).first

    if existence?
      histories.build(exist_quantity: latest_history.quantity)
    elsif number?
      histories.build(exist_quantity: 1, num_quantity: latest_history.quantity)
    end
  end

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
