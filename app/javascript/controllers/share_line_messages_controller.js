import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share-line-messages"
export default class extends Controller {
  static values = {
    liffId: String,
    message: String,
    redirectUrl: String
  };

  async connect() {
    try {
      // liffの初期化（外部ブラウザでログインする設定を有効にする）
      await liff.init({ 
        liffId: this.liffIdValue,
        withLoginOnExternalBrowser: true
      });

      // URLからliffのパラメータを削除して、履歴を置換する
      history.replaceState({}, "", this.redirectUrlValue);

      const message = this.messageValue;

      // editでmessageを編集していればsessionが空になることはないが、空ならログを出す
      if (message == "") {
        console.warn("LINE share message is null");
        alert("メッセージが未入力です。\n「LINEで買いもの依頼」画面からメッセージを編集してください。");
      }

      // シェアターゲットピッカーを起動し、送信後に画面を閉じる
      await liff.shareTargetPicker([
        { type: "text", text: this.messageValue }
      ]);
      liff.closeWindow();

    } catch (e) {
      console.error(e);
      alert("ポップアップブロックがされている場合はLINEが起動しません。\nブラウザの設定からポップアップとリダイレクトを許可してください。");
    }
  }
}
