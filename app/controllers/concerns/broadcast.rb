# ActionCableで配信するサービスクラスオブジェクト

module Broadcast
  extend ActiveSupport::Concern

  private

  def broadcast
    BroadcasterServices.new(current_user, current_list_type, current_sort_mode)
  end
end
