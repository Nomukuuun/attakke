# TODO: テストが済んだら削除

class PushTestController < ApplicationController
  before_action :authenticate_user!

  def test
    message = {
      title: "Attakke? テスト通知",
      body: "これはプッシュ通知の動作確認です 📱"
    }

    current_user.send_push_notification(message: message)
    flash.now[:success] = "プッシュ通知テストな～り"
    render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_message")
  end
end
