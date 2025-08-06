import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="templete-toggle"
export default class extends Controller {
  static targets = ["content"];

  toggle(event) {
    const toggleId = event.currentTarget.dataset.toggleTarget;
    const contentElement = document.getElementById(toggleId);
    if (contentElement) {
      contentElement.classList.toggle("hidden");
    }
  }
}
