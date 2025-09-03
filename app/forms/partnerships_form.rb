# パートナー申請のメールアドレス入力フォーム用
class PartnershipsForm
  include ActiveModel::Model 
  include ActiveModel::Attributes

  attribute :gmail, :string
  attribute :current_user_email, :string

  validates :gmail, presence: { message: "が入力されていません" }
  validate :own_gmail_or_blank

  def own_gmail_or_blank
    errors.add(:gmail, "アドレスはパートナーに設定するユーザーのものを入力してください") if "#{gmail}@gmail.com" == current_user_email
  end
end
