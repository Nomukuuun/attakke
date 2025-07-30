class Stock < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :model, presence: true, length: { maximum: 255 }

  enum :model, { existence: 0, number: 1 }

  belongs_to :user
  belongs_to :location
  has_many :histories, dependent: :destroy

  accepts_nested_attributes_for :histories

  # index画面で〇日前と表示するためのメソッド
  def number_of_days_elapsed
    return "履歴なし" unless latest_recording_date

    elapsed_days = Date.today - latest_recording_date.to_date
    elapsed_days.to_i == 0 ? "今日" : "#{elapsed_days.to_i}日前"
  end
end
