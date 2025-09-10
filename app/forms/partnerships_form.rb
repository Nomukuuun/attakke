# パートナー申請のメールアドレス入力フォーム用
class PartnershipsForm
  include ActiveModel::Model 
  include ActiveModel::Attributes

  attribute :gmail, :string
  attribute :current_user_email, :string

  validates :gmail, presence: { message: "が入力されていません" }
  validate :own_gmail

  def own_gmail
    errors.add(:gmail, "アドレスはパートナーに設定するユーザーのアドレスを入力してください") if "#{gmail}@gmail.com" == current_user_email
  end
end
