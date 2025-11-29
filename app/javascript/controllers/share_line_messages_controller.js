import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share-line-messages"
export default class extends Controller {
  static values = {
    liffId: String,
    message: String,
  };

  async connect() {
    try {
      // liffの初期化（外部ブラウザでログインする設定を有効にする）
      await liff.init({ 
        liffId: this.liffIdValue,
        withLoginOnExternalBrowser: true
      });

      // ここでliffにログインしてアクセストークンを取得
      if (!liff.isLoggedIn()) {
        // withLoginOnExternalBrowser:trueにしているため、未ログイン状態になることはないが、ログを出すようにする
        console.warn("Not logged in.");
        alert("LINEへのログインに失敗しました");
        return;
      }

      // シェアターゲットピッカーを起動し、送信後に画面を閉じる
      await liff.shareTargetPicker([
        { type: "text", text: this.messageValue }
      ]);
      liff.closeWindow();

    } catch (e) {
      console.error(e);
      alert("LINEアプリ内で開いているか確認してください");
    }
  }
}
