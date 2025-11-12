# ActionCableで配信するサービスクラスオブジェクト

module Broadcast
  extend ActiveSupport::Concern

  private

  def broadcast
    Broadcaster.new(current_user, current_list_type_value, current_sort_mode_value)
  end
end
