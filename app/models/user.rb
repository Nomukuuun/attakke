class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  # provider/uid は外部認証の識別子なので変更を禁止
  attr_readonly :provider, :uid

  has_many :partnerships, dependent: :destroy
  has_many :partners, through: :partnerships, source: :partner
  has_many :stocks, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :histories, through: :stocks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # ActiveRecord::Relationで世帯のユーザー、ストック、保管場所群を返す
  def household_user_ids
    ids = [ id ]
    ids << active_partner.id if active_partnership&.approved?
    ids
  end

  def household_users
    self.class.where(id: household_user_ids)
  end

  def household_stocks
    Stock.where(user_id: household_user_ids)
  end

  def household_locations
    Location.where(user_id: household_user_ids)
  end

  # ActionCable用のストリームキー
  # nilを排除してからソートすることでidが "小さなユーザー"_"大きなユーザー" のキーを生成する
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

  # ユーザー情報未登録ならGoogleアカウントの情報を登録する
  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end

  # パスワードはログインに使わないため、空でもOKにする
  def password_required?
    false
  end
end
