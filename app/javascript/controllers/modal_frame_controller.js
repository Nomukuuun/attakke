import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal-frame"
export default class extends Controller {
  static targets = ["modal", "dialog"];
  static values = { locationId: String };

  connect() {}
  disconnect() {}

  // form送信が成功したときにモーダルを閉じる
  close(event) {
    // event.detail.successは、レスポンスが成功ならtrueを返す。
    // バリデーションエラー時は、falseを返す。
    console.log("closeアクション");
    if (event.detail.success) {
      this.modalTarget.classList.add("hidden");
    }
  }

  // dialog内をクリックしたときにclickOutsideまで伝搬しないようにする
  stopPropagation(event) {
    if (event.target.closest("a")) return;
    event.stopPropagation();
  }

  // dialog外をクリックしたときにモーダルを閉じる
  clickOutside(event) {
    if (!this.dialogTarget.contains(event.target)) {
      console.log("clickOutsideアクション");
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
    console.log("hideアクション");
    this.modalTarget.classList.add("hidden");
  }
}
