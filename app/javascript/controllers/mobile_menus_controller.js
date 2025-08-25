import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="mobile-menus"
export default class extends Controller {
  static targets = ["open", "close", "mobileMenus"];

  connect() {
    this.outsideClickHandler = this.closeIfOutside.bind(this);
  }

  toggle() {
    this.openTarget.classList.toggle("hidden");
    this.closeTarget.classList.toggle("hidden");
    this.mobileMenusTarget.classList.toggle("hidden");

    if (!this.mobileMenusTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.outsideClickHandler);
    } else {
      document.removeEventListener("click", this.outsideClickHandler);
    }
  }

  closeIfOutside(event) {
    if (this.element.contains(event.target)) return; // 自分の中のクリックは無視
    this.reset();
  }

  reset() {
    this.openTarget.classList.remove("hidden");
    this.closeTarget.classList.add("hidden");
    this.mobileMenusTarget.classList.add("hidden");
    document.removeEventListener("click", this.outsideClickHandler);
  }
}
