class Partnership < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: "User"

  enum status: { pending: 0, approved: 1 }

  validates :user_id, uniqueness: { scope: :partner_id }

  before_create :generate_token

  after_create :create_inverse
  after_update :update_inverse
  after_destroy :destroy_inverse

  scope :active, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :expired, -> { pending.where("expires_at < ?", Time.current) }

  private

  def generate_token
    self.token ||= Devise.friendly_token[0, 20]
  end

  # 双方向レコード作成
  def create_inverse
    self.class.create(user: partner, partner: user, status: status, expires_at: expires_at, token: self.generate_token)
  end

  # 双方向レコード更新
  def update_inverse
    inverse = self.class.find_by(user: partner, partner: user)
    inverse&.update_columns(status: status, expires_at: expires_at, updated_at: Time.current)
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
