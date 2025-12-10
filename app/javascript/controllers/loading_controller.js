import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    // 初回画面表示、Googleログイン画面でのキャンセル、ブラウザバック時にアニメーションを非表示にする
    window.addEventListener("pageshow", () => {
      this.hide();
    });
  }

  show() {
    this.overlayTarget.classList.remove("hidden");
  }

  hide() {
    this.overlayTarget.classList.add("hidden");
  }
}
