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

  # ペアレコードの双方向作成、更新、削除に関するロジック
  def pair
    self.class
      .where(user_id: partner_id, partner_id: user_id)
      .active
      .order(id: :desc)
      .first!
  end

  def approve_pair!
    self.class.transaction do
      update!(status: :approved)
      pair.update!(status: :approved)
    end
  end

  def destroy_pair!
    self.class.transaction do
      destroy!
      pair.destroy!
    end
  end

  def self.create_request_pair!(user, partner_user)
    transaction do
      applicant = user.partnerships.create!(partner_id: partner_user.id, status: :sended)
      partner_user.partnerships.create!(partner_id: user.id, status: :pending, expires_at: applicant.expires_at)
    end
  end

  # NOTE: 以下private
  private

  def set_expires_at
    self.expires_at ||= 30.minutes.from_now
  end
end
