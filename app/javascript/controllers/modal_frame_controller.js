import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal-frame"
export default class extends Controller {
  static targets = ["modal", "dialog"];
  static values = { locationId: String };

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

  // dialog外をクリックしたときにモーダルを閉じる
  clickOutside(event) {
    if (!this.dialogTarget.contains(event.target)) {
      this.hideModal();
    }
  }

  // 特定の保管場所までスクロールする
  selectLocation(event) {
    const id = event.currentTarget.dataset.locationIdValue;
    this.hideModal();

    setTimeout(() => {
      const target = document.getElementById(id);
      if (target) {
        const offset = 128; // top-32 分の高さ
        const targetPosition =
          target.getBoundingClientRect().top + window.scrollY;
        const scrollTo = targetPosition - offset;

        window.scrollTo({
          top: scrollTo,
          behavior: "smooth",
        });
      }
    }, 100);
  }

  hideModal() {
    this.modalTarget.classList.add("hidden");
  }
}
