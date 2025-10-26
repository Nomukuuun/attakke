class Partnership < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: "User"

  enum :status, { sended: 0, pending: 1, approved: 2 }

  validates :user_id, uniqueness: { scope: %i[partner_id expires_at] }

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :approved_only, -> { where(status: :approved) }
  scope :waiting, -> { where(status: [ :sended, :pending ]) }

  # 新規レコード作成時に有効期限（30分）を設定する
  before_create :set_expires_at

  # 一方向のレコードを作成、更新、削除したことをトリガーに反対方向のレコードを操作する
  after_create :create_inverse, unless: :has_inverse?
  after_update :update_inverse, if: -> { saved_change_to_status? && has_inverse? }
  after_destroy :destroy_inverse, if: :has_inverse?

  private

  def set_expires_at
    self.expires_at ||= 30.minutes.from_now
  end

  # 双方向レコード作成
  def create_inverse
    self.class.create(user: partner, partner: user, expires_at: expires_at, status: :pending)
  end

  # 双方向レコード更新
  def update_inverse
    inverse = self.class.where(user: partner, partner: user).active.first
    inverse&.update_columns(status: :approved)
  end

  # 双方向レコード削除
  def destroy_inverse
    inverse = self.class.where(user: partner, partner: user).active.first
    inverse&.destroy
  end

  # 双方向レコード存在確認
  def has_inverse?
    self.class.where(user: partner, partner: user).active.exists?
  end
end
