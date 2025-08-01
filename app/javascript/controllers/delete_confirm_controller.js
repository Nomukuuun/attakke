import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="delete-confirm"
export default class extends Controller {
  static targets = [
    "modal",
    "dialog",
    "message",
    "confirmButton",
    "cancelButton",
  ];

  connect() {
    Turbo.setConfirmMethod((message, element) => {
      return this.showModal(message, element);
    });
  }

  showModal(message, element) {
    this.resolve = null;
    return new Promise((resolve) => {
      this.resolve = resolve;
      this.messageTarget.innerHTML = message;
      this.modalTarget.classList.remove("hidden");
    });
  }

  confirm() {
    this.hideModal();
    if (this.resolve) {
      this.resolve(true);
    }
  }

  cancel() {
    this.hideModal();
    if (this.resolve) {
      this.resolve(false);
    }
  }

  clickOutside(event) {
    if (!this.dialogTarget.contains(event.target)) {
      this.cancel();
    }
  }

  hideModal() {
    this.modalTarget.classList.add("hidden");
  }
}
