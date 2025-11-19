import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    document.addEventListener("turbo:before-visit", () => this.show());
    document.addEventListener("turbo:load", () => this.hide());
  }

  show() {
    this.overlayTarget.classList.remove("hidden");
  }

  hide() {
    this.overlayTarget.classList.add("hidden");
  }
}
