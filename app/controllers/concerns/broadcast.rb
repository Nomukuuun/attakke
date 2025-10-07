# ActionCableで配信するサービスクラスオブジェクト

module Broadcast
  extend ActiveSupport::Concern

  private

  def broadcast
    Broadcaster.new(current_user)
  end
end
