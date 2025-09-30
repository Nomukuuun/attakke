# パートナー申請のメールアドレス入力フォーム用
class PartnershipsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :current_user_email, :string

  validates :email, presence: { message: "が入力されていません" }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "の形式が正しくありません" }
  validate :own_email

  private

  def own_email
    errors.add(:email, "アドレスはパートナーに設定するユーザーのアドレスを入力してください") if email == current_user_email
  end
end
