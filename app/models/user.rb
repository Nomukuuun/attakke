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
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  has_many :stocks, dependent: :destroy

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end
end
