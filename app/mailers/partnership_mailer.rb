class PartnershipMailer < ApplicationMailer
  def send_gmail(partnership, partner)
    @partnership = partnership
    @partner = partner
    mail(to: @partner.email, subject: "【Attakke?】パートナー申請が届いています！")
  end
end
