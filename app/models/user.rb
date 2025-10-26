# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  partner_id :integer
#  email      :string(255)      default(""), not null
#  encrypted_password :string(255) default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  provider   :string(255)
#  uid        :string(255)
#
# Indexes
#  index_users_on_email  (email) UNIQUE

class User < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  has_many :partnerships, dependent: :destroy
  has_many :partners, through: :partnerships, source: :partner
  has_many :stocks, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :histories, through: :stocks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # ActionCable用のストリームキー
  # nilを排除してからソートすることでパートナーシップにより紐づいている２人を表現できる
  def partnership_stream_key
    approved_partner = active_partner if active_partnership&.approved?
    [ id, approved_partner&.id ].compact.sort.join("_")
  end

  # ユーザーに登録されている端末情報の数だけプッシュ通知を送る
  def send_push_notification(message:, url: "/")
    subscriptions.find_each do |subscription|
      PushNotificationJob.perform_later(subscription.id, message: message, url: url)
    end
  end

  # 承認済みまたは保留中の状態のレコード１件を取得
  def active_partnership
    partnerships.approved_only.order(expires_at: :desc).first ||
    partnerships.waiting.active.order(expires_at: :asc).first
  end

  # 有効なパートナーシップレコードがあるならパートナーを返す
  def active_partner
    active_partnership&.partner
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end
end
