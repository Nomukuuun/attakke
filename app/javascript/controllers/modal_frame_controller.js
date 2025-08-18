import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal-frame"
export default class extends Controller {
  static targets = ["modal", "dialog"];

  // modal_frame外の要素が削除された際にモーダルを非表示にする
  connect() {
    document.addEventListener(
      "turbo:before-stream-render",
      this.beforeStreamRender
    );
  }

  disconnect() {
    // コントローラが外れたときにイベントリスナを解除
    document.removeEventListener(
      "turbo:after-stream-render",
      this.beforeStreamRender
    );
  }

  beforeStreamRender = () => {
    // DOMを走査してmodalがhiddenになっていないなら閉じる
    if (!this.modalTarget.classList.contains("hidden")) {
      this.hideModal();
    }
  };

  // form送信が成功したときにモーダルを閉じる
  close(event) {
    // event.detail.successは、レスポンスが成功ならtrueを返す。
    // バリデーションエラー時は、falseを返す。
    if (event.detail.success) {
      this.modalTarget.classList.add("hidden");
    }
  }

  clickOutside(event) {
    if (!this.dialogTarget.contains(event.target)) {
      this.hideModal();
    }
  }

  hideModal() {
    this.modalTarget.classList.add("hidden");
  }
}
