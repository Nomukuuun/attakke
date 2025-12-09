class History < ApplicationRecord
  validates :exist_quantity, inclusion: { in: [ 0, 1 ] }, if: -> { stock.existence? }
  validates :num_quantity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: "は必須入力です" }, if: -> { stock.number? }
  validates :status, presence: true
  validates :recording_date, presence: true

  # ユーザー操作によらない値を保存前にセットする
  before_validation :set_status_and_date
  before_validation :nillify_unused_quantity

  # purchaseは「購入」、consumptionは「消費」、maintenanceは「記録のみ」
  enum :status, { purchase: 0, consumption: 1, maintenance: 2 }

  belongs_to :stock

  # ストックごとの最新履歴をまとめて取得するためのサブクエリ用scope
  scope :latest, -> { select("DISTINCT ON (stock_id) *").order(:stock_id, id: :desc, recording_date: :desc) }

  # ストック型に関係なく直近の数量を返す
  def quantity
    stock.existence? ? exist_quantity.to_i : num_quantity.to_i
  end

  # DB保存済の直近履歴を返す
  def recent_history
    stock.histories.where.not(id: self.id).order(id: :desc).first
  end

  # NOTE: 以下、privateメソッド
  private

  # ユーザーからの入力値によらない「履歴更新日」と「状態」を保存前にセット
  def set_status_and_date
    self.recording_date = Date.today

    # countが０なら今回が新規作成 ＝ createアクション
    if stock.histories.count == 0 || update_model?
      self.status = quantity == 0 ? :consumption : :purchase
    else
      set_status_for_update
    end
  end

  def set_status_for_update
    if update_quantity?

      diff = recent_history&.quantity - self.quantity.to_i
      self.status =
        case diff <=> 0
        when 1  then :consumption
        when -1 then :purchase
        end

    elsif update_purchase_target?

      # purchase_targetがtrueへ変更 = 購入対象に入れたことを意味するため「消費」表示
      self.status = stock.purchase_target == true ? :consumption : :purchase

    else # 何も操作せずに保存、または、ストック名のみ変更
      self.status = :maintenance
    end
  end

  # 使用しない型の数量をnilにしてから保存
  def nillify_unused_quantity
    case stock.model
    when "existence"
      self.num_quantity = nil
    when "number"
      self.exist_quantity = nil
    end
  end

  # 更新判定ロジック
  def update_model?
    stock.changes.has_key?(:model)
  end

  def update_purchase_target?
    stock.changes.has_key?(:purchase_target)
  end

  def update_quantity?
    recent_history&.quantity != self.quantity
  end
end
