module Broadcaster
  extend ActiveSupport::Concern

  private

  # ActionCableで配信を担うサービスクラスオブジェクトを生成する
  def broadcaster
    BroadcasterServices.new(current_user, current_list_type, current_sort_mode)
  end
end
