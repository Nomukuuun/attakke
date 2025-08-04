class History < ApplicationRecord
  validates :exist_quantity, inclusion: { in: [0, 1] }, if: -> { stock.existence? }
  validates :num_quantity, numericality: { greater_than_or_equal_to: 0, less_than: 100, message: "は必須入力です" }, if: -> { stock.number? }
  before_validation :set_status_and_date
  before_validation :nillify_unused_quantity

  enum :status, { purchase: 0, consumption: 1, maintenance: 2 }

  belongs_to :stock

  def quantity
    stock.existence? ? exist_quantity.to_i : num_quantity.to_i
  end

  private

  # フォームから受け取らないカラムを保存前に設定
  def set_status_and_date
    self.recording_date ||= Date.today
    return if status.in?([0, 1])

    if stock.histories.size == 1
      # create時のstatus設定
      self.status = quantity == 0 ? :consumption : :purchase
    else
      # update時のstatus設定
      update_status_based_on_previous_history
    end
  end

  def update_status_based_on_previous_history
    return unless stock

    # stock型の変更有無又は保存済の履歴の有無によって分岐
    update_stock_model = stock.changes.has_key?(:model)
    previous_history = stock.histories.where.not(id: id).order(id: :desc).first
    return self.status = quantity == 0 ? :consumption : :purchase if previous_history.blank? || update_stock_model

    old_quantity = stock.existence? ? previous_history.exist_quantity.to_i : previous_history.num_quantity.to_i
    diff = old_quantity - quantity

    self.status =
      case diff <=> 0
      when 1  then :consumption
      when -1 then :purchase
      # TODO: 数量を変更しなかったときは履歴のみ更新するロジックを作る
      when 0 then :maintenance
      end
  end

  # 使用しない型のquantityをnilにしてから保存
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
