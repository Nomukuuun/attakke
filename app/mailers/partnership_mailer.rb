class PartnershipMailer < ApplicationMailer
  # 受信者へのメール
  def send_gmail_to_recipient(partnership, partner)
    @partnership = partnership
    @partner = partner
    mail(to: @partner.email, subject: "【Attakke?】パートナー申請が届いています！")
  end

  # 申請者へのメール
  def send_gmail_to_applicant(partner)
    @partner = partner
    mail(to: @partner.email, subject: "【Attakke?】パートナー申請が承諾されました！")
  end
end
