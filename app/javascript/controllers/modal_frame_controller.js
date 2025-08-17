import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal-frame"
export default class extends Controller {
  static targets = ["modal", "dialog"];

  connect() {}

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
