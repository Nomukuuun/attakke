class History < ApplicationRecord
  validates :exist_quantity, inclusion: { in: [ 0, 1 ] }, if: -> { stock.existence? }
  validates :num_quantity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: "は必須入力です" }, if: -> { stock.number? }
  validates :status, presence: true
  validates :recording_date, presence: true

  before_validation :set_status_and_date
  before_validation :nillify_unused_quantity

  # purchaseは「購入」、consumptionは「消費」、maintenanceは「記録のみ」にコミット
  # maintenanceはストック型や個数に変化がない更新時にセットされる
  enum :status, { purchase: 0, consumption: 1, maintenance: 2 }

  belongs_to :stock

  # ストックごとの最新履歴をまとめて取得するためのサブクエリ用scope
  scope :latest, -> { select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc) }

  def quantity
    stock.existence? ? exist_quantity.to_i : num_quantity.to_i
  end

  private

  # ユーザーからの入力値によらない「履歴更新日」と「状態」を保存前にセット
  def set_status_and_date
    self.recording_date = Date.today

    if stock.histories.size.in?([ 0, 1 ])
      # stocks/create時のstatus設定
      self.status = quantity == 0 ? :consumption : :purchase
    else
      # stocks/update時のstatus設定
      update_status_based_on_previous_history
    end
  end

  def update_status_based_on_previous_history
    return unless stock

    # ストック型の変更がない、または履歴が１件もない場合は新規保存時と同様にstatusをセット
    update_stock_model = stock.changes.has_key?(:model)
    previous_history = stock.histories.where.not(id: id).order(id: :desc).first
    return self.status = quantity == 0 ? :consumption : :purchase if previous_history.blank? || update_stock_model

    # 更新時はストック数の差分に応じてstatusをセット
    old_quantity = stock.existence? ? previous_history.exist_quantity.to_i : previous_history.num_quantity.to_i
    diff = old_quantity - quantity

    self.status =
      case diff <=> 0
      when 1  then :consumption
      when -1 then :purchase
      when 0 then :maintenance # 差分がない＝ストック名または保管場所の移転による更新
      end
  end

  # 使用しない型の数量をnilにしてから保存
  def nillify_unused_quantity
    return unless stock

    case stock.model
    when "existence"
      self.num_quantity = nil
    when "number"
      self.exist_quantity = nil
    end
  end
end
