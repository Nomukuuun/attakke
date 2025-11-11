# ActionCableで配信するサービスクラスオブジェクト

module Broadcast
  extend ActiveSupport::Concern

  private

  def broadcast
    Broadcaster.new(current_user, current_list_type_value)
  end
end
