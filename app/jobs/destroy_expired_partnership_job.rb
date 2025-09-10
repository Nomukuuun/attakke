class DestroyExpiredPartnershipJob < ApplicationJob
  queue_as :default

  def perform(partnership_id)
    partnership = Partnership.find_by(id: partnership_id)
    return unless partnership&.sended?
    partnership.destroy!
  end
end
