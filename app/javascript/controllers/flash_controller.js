import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["close"];

  close() {
    this.element.classList.add("hidden");
  }
}
