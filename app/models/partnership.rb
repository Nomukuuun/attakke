class Partnership < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: "User"

  enum :status, { sended: 0, pending: 1, approved: 2 }

  validates :user_id, uniqueness: { scope: :partner_id }

  before_create :set_token_and_expires_at

  after_create :create_inverse, unless: :has_inverse?
  after_update :update_inverse, if: :has_inverse?
  after_destroy :destroy_inverse, if: :has_inverse?

  scope :active, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :expired, -> { pending.where("expires_at < ?", Time.current) }

  private

  def set_token_and_expires_at
    self.token = Devise.friendly_token[0, 20]
    self.expires_at = 30.minutes.from_now
  end

  # 双方向レコード作成
  def create_inverse
    self.class.create(user: partner, partner: user, status: :pending)
  end

  # 双方向レコード更新
  def update_inverse
    inverse = self.class.find_by(user: partner, partner: user)
    inverse&.update_columns(status: :approved, token: nil)
  end

  # 双方向レコード削除
  def destroy_inverse
    self.class.find_by(user: partner, partner: user)&.destroy
  end

  # 双方向レコード存在確認
  def has_inverse?
    self.class.exists?(user: partner, partner: user)
  end
end
